import Foundation

/// Request body for API 1: Generate Token (Login)
struct LoginRequest: Encodable {
    let username: String
    let password: String
    let loginType: String
}

/// Response payload from API 1: Generate Token (Login)
struct LoginResponse: Decodable {
    let success: Bool
    let message: String?
    let response: LoginData?
}

/// Token and user details returned on successful login
struct LoginData: Decodable {
    let username: String?
    let jwtToken: String?
    let senderId: String?
    let baseUrl: String?
    let serverPath: String?

    enum CodingKeys: String, CodingKey {
        case username = "Username"
        case jwtToken = "Jwt_Token"
        case senderId = "SenderId"
        case baseUrl = "BaseUrl"
        case serverPath = "ServerPath"
    }
}
