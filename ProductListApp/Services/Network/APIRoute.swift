import Foundation

/// Centralized API Routes matching the PDF specifications
enum APIRoute {
    case login(request: LoginRequest)
    case getProducts(sfCode: String, stateCode: Int, divisionCode: Int, hqSfCode: String)
    case getStateRate(sfCode: String, stateCode: Int, divisionCode: Int, hqSfCode: String)
    case saveOrder(request: SaveOrderRequest)

    private var baseURL: String {
        return "http://sjapi.salesjump.in"
    }

    var path: String {
        switch self {
        case .login:
            return "/api/ioslogin"
        case .getProducts, .getStateRate:
            return "/api/qc/getmasterSync"
        case .saveOrder:
            return "/api/qc/SaveSampleIos"
        }
    }

    var method: String {
        switch self {
        case .login, .saveOrder:
            return "POST"
        case .getProducts, .getStateRate:
            return "GET"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .login, .saveOrder:
            return nil
        case .getProducts(let sfCode, let stateCode, let divisionCode, let hqSfCode):
            return [
                URLQueryItem(name: "Master_Name", value: "Products"),
                URLQueryItem(name: "SF_Code", value: sfCode),
                URLQueryItem(name: "State_Code", value: "\(stateCode)"),
                URLQueryItem(name: "Division_Code", value: "\(divisionCode)"),
                URLQueryItem(name: "HqSf_Code", value: hqSfCode)
            ]
        case .getStateRate(let sfCode, let stateCode, let divisionCode, let hqSfCode):
            return [
                URLQueryItem(name: "Master_Name", value: "StateRate"),
                URLQueryItem(name: "SF_Code", value: sfCode),
                URLQueryItem(name: "State_Code", value: "\(stateCode)"),
                URLQueryItem(name: "Division_Code", value: "\(divisionCode)"),
                URLQueryItem(name: "HqSf_Code", value: hqSfCode)
            ]
        }
    }

    var httpBody: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .login(let req):
            return try? encoder.encode(req)
        case .saveOrder(let req):
            return try? encoder.encode(req)
        case .getProducts, .getStateRate:
            return nil
        }
    }

    /// Assembles the complete URLRequest with headers
    func makeURLRequest(token: String? = nil) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        if let queryItems = queryItems {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = httpBody {
            request.httpBody = body
        }

        return request
    }
}
