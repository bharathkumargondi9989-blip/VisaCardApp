import Foundation

/// Protocol defining the repository interface for product retrieval, caching, and order submission
protocol ProductRepositoryProtocol {
    func authenticate() async throws -> String
    func fetchAndSyncProducts() async throws -> [ProductItem]
    func getCachedProducts() -> [ProductItem]
    func updateProductQuantity(id: String, quantity: Int)
    func saveOrder(remarks: String, selectedProducts: [ProductItem]) async throws -> String
    func resetQuantities()
}
