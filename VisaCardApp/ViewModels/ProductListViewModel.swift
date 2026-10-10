import Foundation

/// Primary ViewModel orchestrating product listing, reactive totals, and order submission
final class ProductListViewModel: ProductListViewModelProtocol {
    private let repository: ProductRepositoryProtocol

    private(set) var productViewModels: [ProductItemViewModel] = []

    private(set) var state: ProductListViewState = .idle {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.onStateChange?(self.state)
            }
        }
    }

    var onStateChange: ((ProductListViewState) -> Void)?
    var onTotalsUpdated: (() -> Void)?

    // MARK: - Reactive Summary Calculations

    /// Total Items: Number of distinct products with quantity > 0
    var totalItems: Int {
        return productViewModels.filter { $0.quantity > 0 }.count
    }

    /// Total Qty: Sum of quantities across all products
    var totalQuantity: Int {
        return productViewModels.reduce(0) { $0 + $1.quantity }
    }

    /// Total Amount: Sum of (retailerPrice * quantity)
    var totalAmount: Double {
        return productViewModels.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var formattedTotalAmount: String {
        return String(format: "₹ %.2f", totalAmount)
    }

    /// Save button is enabled only when cart contains at least one item
    var isSaveEnabled: Bool {
        return totalQuantity > 0
    }

    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
    }

    // MARK: - Intent Methods

    /// Loads cached data first for instant UI, then syncs with remote APIs
    func loadProducts() {
        // 1. Immediately display cached products if available (Offline-first)
        let cached = repository.getCachedProducts()
        if !cached.isEmpty {
            self.productViewModels = cached.map { ProductItemViewModel(product: $0) }
            self.state = .loaded
            self.notifyTotalsUpdated()
        } else {
            self.state = .loading
        }

        // 2. Fetch fresh data from network
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let syncedItems = try await self.repository.fetchAndSyncProducts()
                await MainActor.run {
                    self.productViewModels = syncedItems.map { ProductItemViewModel(product: $0) }
                    self.state = .loaded
                    self.notifyTotalsUpdated()
                }
            } catch {
                await MainActor.run {
                    // If network fails but we had cached items, keep showing cached items with non-intrusive warning
                    if !self.productViewModels.isEmpty {
                        self.state = .loaded
                    } else {
                        self.state = .error(message: error.localizedDescription)
                    }
                }
            }
        }
    }

    /// Increments quantity for item at specified index
    func incrementQuantity(at index: Int) {
        guard productViewModels.indices.contains(index) else { return }
        let itemVM = productViewModels[index]
        itemVM.increment()
        repository.updateProductQuantity(id: itemVM.id, quantity: itemVM.quantity)
        notifyTotalsUpdated()
    }

    /// Decrements quantity for item at specified index
    func decrementQuantity(at index: Int) {
        guard productViewModels.indices.contains(index) else { return }
        let itemVM = productViewModels[index]
        itemVM.decrement()
        repository.updateProductQuantity(id: itemVM.id, quantity: itemVM.quantity)
        notifyTotalsUpdated()
    }

    /// Directly sets quantity for item at specified index (via TextField input)
    func setQuantity(at index: Int, quantity: Int) {
        guard productViewModels.indices.contains(index) else { return }
        let itemVM = productViewModels[index]
        let validQuantity = max(0, quantity)
        itemVM.quantity = validQuantity
        repository.updateProductQuantity(id: itemVM.id, quantity: validQuantity)
        notifyTotalsUpdated()
    }

    /// Submits order with remarks to the Save API
    func submitOrder(remarks: String) {
        let trimmedRemarks = remarks.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRemarks.isEmpty else {
            self.state = .error(message: "Please enter remarks before saving.")
            return
        }

        let selectedItems = productViewModels
            .filter { $0.quantity > 0 }
            .map { $0.product }

        guard !selectedItems.isEmpty else {
            self.state = .error(message: "Cart is empty. Please select product quantity.")
            return
        }

        self.state = .saving

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let successMessage = try await self.repository.saveOrder(
                    remarks: trimmedRemarks,
                    selectedProducts: selectedItems
                )
                await MainActor.run {
                    // Reset all quantities locally
                    for vm in self.productViewModels {
                        vm.quantity = 0
                    }
                    self.notifyTotalsUpdated()
                    self.state = .saveSuccess(message: successMessage)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(message: "Failed to save order: \(error.localizedDescription)")
                }
            }
        }
    }

    private func notifyTotalsUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.onTotalsUpdated?()
        }
    }
}
