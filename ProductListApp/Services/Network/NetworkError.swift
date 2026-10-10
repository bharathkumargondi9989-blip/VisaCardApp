import Foundation

/// Application Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case authenticationFailed(String)
    case serverError(statusCode: Int, message: String)
    case decodingFailed(Error)
    case networkUnavailable
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        case .serverError(let statusCode, let message):
            return "Server returned error \(statusCode): \(message)"
        case .decodingFailed(let error):
            return "Failed to parse data from server: \(error.localizedDescription)"
        case .networkUnavailable:
            return "Network connection appears to be offline. Using cached data."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
