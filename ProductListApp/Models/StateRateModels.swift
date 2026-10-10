import Foundation

/// API 3 StateRate Master Response
struct StateRateResponse: Decodable {
    let success: Bool
    let message: String?
    let dataCount: Int?
    let masterName: String?
    let response: [StateRateDTO]
}

/// DTO for each item returned in API 3 StateRate sync
struct StateRateDTO: Decodable {
    let stateCode: Int?
    let divisionCode: Int?
    let productDetailCode: String
    let retailerPrice: String?
    let retailCasePrice: String?
    let mrpPrice: String?
    let minPrice: String?

    enum CodingKeys: String, CodingKey {
        case stateCode = "State_Code"
        case divisionCode = "Division_Code"
        case productDetailCode = "Product_Detail_Code"
        case retailerPrice = "Retailor_Price"
        case retailCasePrice = "RetailCasePrice"
        case mrpPrice = "MRP_Price"
        case minPrice = "Min_price"
    }

    /// Helper to convert string price to numeric Double
    var parsedRetailerPrice: Double {
        guard let priceString = retailerPrice?.trimmingCharacters(in: .whitespacesAndNewlines),
              let price = Double(priceString) else {
            return 0.0
        }
        return price
    }
}
