import Foundation

/// Item ViewModel representing an individual product in the list
final class ProductItemViewModel: Equatable {
    private(set) var product: ProductItem

    var id: String { product.id }
    var name: String { product.name }
    var code: String { product.code }
    var price: Double { product.retailerPrice }
    var quantity: Int {
        get { product.quantity }
        set { product.quantity = max(0, newValue) }
    }

    var formattedPrice: String {
        return String(format: "₹ %.2f", product.retailerPrice)
    }

    var formattedTotalValue: String {
        return String(format: "₹ %.2f", product.totalValue)
    }

    init(product: ProductItem) {
        self.product = product
    }

    func increment() {
        quantity += 1
    }

    func decrement() {
        if quantity > 0 {
            quantity -= 1
        }
    }

    static func == (lhs: ProductItemViewModel, rhs: ProductItemViewModel) -> Bool {
        return lhs.product == rhs.product
    }
}
