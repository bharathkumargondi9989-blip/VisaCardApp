import Foundation

/// UI View state representation
enum ProductListViewState: Equatable {
    case idle
    case loading
    case loaded
    case saving
    case error(message: String)
    case saveSuccess(message: String)
}

/// Protocol defining the ProductListViewModel interface
protocol ProductListViewModelProtocol: AnyObject {
    var state: ProductListViewState { get }
    var productViewModels: [ProductItemViewModel] { get }
    var totalItems: Int { get }
    var totalQuantity: Int { get }
    var totalAmount: Double { get }
    var formattedTotalAmount: String { get }
    var isSaveEnabled: Bool { get }

    var onStateChange: ((ProductListViewState) -> Void)? { get set }
    var onTotalsUpdated: (() -> Void)? { get set }

    func loadProducts()
    func incrementQuantity(at index: Int)
    func decrementQuantity(at index: Int)
    func setQuantity(at index: Int, quantity: Int)
    func submitOrder(remarks: String)
}
