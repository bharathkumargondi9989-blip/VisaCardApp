import Foundation

/// Real-world implementation of the Product Repository integrating Network and Core Data
final class ProductRepository: ProductRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let coreDataStack: CoreDataStack
    private let sessionManager: SessionManager

    // PDF Configuration constants
    private let defaultSFCode = "sjqamgr0005"
    private let defaultStateCode = 24
    private let defaultDivisionCode = 258
    private let defaultHqSfCode = "sjqamgr0005"

    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        coreDataStack: CoreDataStack = CoreDataStack.shared,
        sessionManager: SessionManager = SessionManager.shared
    ) {
        self.networkService = networkService
        self.coreDataStack = coreDataStack
        self.sessionManager = sessionManager
    }

    /// API 1: Authenticates user credentials and stores the JWT Bearer token
    func authenticate() async throws -> String {
        let loginRequest = LoginRequest(
            username: "sjqa-divya",
            password: "ff@123",
            loginType: "fmcg"
        )
        let response: LoginResponse = try await networkService.execute(
            route: .login(request: loginRequest),
            token: nil
        )

        guard let token = response.response?.jwtToken, !token.isEmpty else {
            throw NetworkError.authenticationFailed(response.message ?? "No token returned")
        }

        sessionManager.jwtToken = token
        if let username = response.response?.username {
            sessionManager.username = username
        }
        return token
    }

    /// Fetches Products (API 2) and Rates (API 3) concurrently, joins them, and saves to Core Data
    func fetchAndSyncProducts() async throws -> [ProductItem] {
        var token = sessionManager.jwtToken
        if token == nil || token?.isEmpty == true {
            token = try await authenticate()
        }

        // Concurrently fetch API 2 (Products) and API 3 (StateRate)
        async let productsTask: ProductMasterResponse = networkService.execute(
            route: .getProducts(
                sfCode: defaultSFCode,
                stateCode: defaultStateCode,
                divisionCode: defaultDivisionCode,
                hqSfCode: defaultHqSfCode
            ),
            token: token
        )

        async let ratesTask: StateRateResponse = networkService.execute(
            route: .getStateRate(
                sfCode: defaultSFCode,
                stateCode: defaultStateCode,
                divisionCode: defaultDivisionCode,
                hqSfCode: defaultHqSfCode
            ),
            token: token
        )

        let (productsResponse, ratesResponse) = try await (productsTask, ratesTask)

        // Build rate dictionary indexed by Product_Detail_Code
        var ratesMap: [String: Double] = [:]
        for rateDTO in ratesResponse.response {
            ratesMap[rateDTO.productDetailCode] = rateDTO.parsedRetailerPrice
        }

        // Fetch existing cached products to retain any user-entered quantities
        let existingProducts = coreDataStack.fetchProducts()
        let existingQtyMap = Dictionary(uniqueKeysWithValues: existingProducts.map { ($0.id, $0.quantity) })

        // Merge Products with Rate (retailer price by product code)
        var mergedItems: [ProductItem] = []
        for prod in productsResponse.response {
            let price = ratesMap[prod.id] ?? 0.0
            let previousQty = existingQtyMap[prod.id] ?? 0

            let item = ProductItem(
                id: prod.id,
                name: prod.name.trimmingCharacters(in: .whitespacesAndNewlines),
                code: prod.code ?? "",
                retailerPrice: price,
                quantity: previousQty,
                divisionCode: prod.divisionCode ?? defaultDivisionCode
            )
            mergedItems.append(item)
        }

        // Persist to local Core Data store
        try await coreDataStack.syncProducts(mergedItems)

        // Return sorted products
        return mergedItems.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Retrieves cached products from Core Data for offline mode
    func getCachedProducts() -> [ProductItem] {
        return coreDataStack.fetchProducts().sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Updates product quantity in Core Data
    func updateProductQuantity(id: String, quantity: Int) {
        coreDataStack.updateProductQuantity(id: id, quantity: quantity)
    }

    /// Saves the order to the server using Page 3 Save API specification
    func saveOrder(remarks: String, selectedProducts: [ProductItem]) async throws -> String {
        var token = sessionManager.jwtToken
        if token == nil || token?.isEmpty == true {
            token = try await authenticate()
        }

        // ISO8601 Formatter for createdDate
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = formatter.string(from: Date())

        let totalQty = selectedProducts.reduce(0) { $0 + $1.quantity }
        let totalAmount = selectedProducts.reduce(0.0) { $0 + $1.totalValue }

        let productDetailsDTOs = selectedProducts.map { item in
            SaveOrderDetailDTO(
                product_Code: item.id,
                product_Name: item.name,
                qty: "\(item.quantity)",
                value: String(format: "%.2f", item.totalValue)
            )
        }

        let saveRequest = SaveOrderRequest(
            userName: sessionManager.username,
            createdDate: dateString,
            totalItems: "\(selectedProducts.count)",
            totalQty: "\(totalQty)",
            totalAmount: totalAmount,
            remarks: remarks,
            productDetails: productDetailsDTOs
        )

        let response: SaveOrderResponse = try await networkService.execute(
            route: .saveOrder(request: saveRequest),
            token: token
        )

        // On successful save, reset quantities
        resetQuantities()

        return response.message ?? "Order saved successfully."
    }

    /// Resets all local quantities to zero
    func resetQuantities() {
        coreDataStack.resetAllQuantities()
    }
}
