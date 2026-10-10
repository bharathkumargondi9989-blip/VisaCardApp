import Foundation

/// API 2 Product Master Response
struct ProductMasterResponse: Decodable {
    let success: Bool
    let message: String?
    let dataCount: Int?
    let masterName: String?
    let response: [ProductDTO]
}

/// DTO for each item returned in API 2 master sync
struct ProductDTO: Decodable {
    let id: String
    let name: String
    let code: String?
    let pSlNo: Int?
    let productUnit: String?
    let unitCode: String?
    let defaultUOM: Int?
    let divisionCode: Int?
    let productDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code = "Code"
        case pSlNo
        case productUnit = "product_unit"
        case unitCode = "Unit_code"
        case defaultUOM = "Default_UOM"
        case divisionCode = "Division_Code"
        case productDescription = "Product_Description"
    }
}

/// Domain model representing a product enriched with its retailer price and selected quantity
struct ProductItem: Identifiable, Equatable {
    let id: String
    let name: String
    let code: String
    let retailerPrice: Double
    var quantity: Int
    let divisionCode: Int

    var totalValue: Double {
        return Double(quantity) * retailerPrice
    }
}
