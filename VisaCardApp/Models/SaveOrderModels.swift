import Foundation

/// Request payload matching PDF Page 3: Save API — Save Product List
struct SaveOrderRequest: Encodable {
    let userName: String
    let createdDate: String
    let totalItems: String
    let totalQty: String
    let totalAmount: Double
    let remarks: String
    let productDetails: [SaveOrderDetailDTO]
}

/// Product details array entry inside Save API
struct SaveOrderDetailDTO: Encodable {
    let product_Code: String
    let product_Name: String
    let qty: String
    let value: String
}

/// Response payload from Save API
struct SaveOrderResponse: Decodable {
    let status: Bool?
    let message: String?
}
