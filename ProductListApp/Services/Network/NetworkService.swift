import Foundation

/// Protocol abstraction for Network Service to enable unit testing and dependency injection
protocol NetworkServiceProtocol {
    func execute<T: Decodable>(route: APIRoute, token: String?) async throws -> T
}

/// Robust URLSession-based network client supporting async/await and JSON decoding
final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func execute<T: Decodable>(route: APIRoute, token: String? = nil) async throws -> T {
        let request = try route.makeURLRequest(token: token)

        #if DEBUG
        print("🌐 [Network] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        #endif

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ [Network] Transport error: \(error.localizedDescription)")
            throw NetworkError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "NetworkService", code: -1, userInfo: nil))
        }

        #if DEBUG
        print("📥 [Network] Status: \(httpResponse.statusCode) for \(request.url?.path ?? "")")
        #endif

        if httpResponse.statusCode == 401 {
            throw NetworkError.authenticationFailed("Session expired or token invalid (HTTP 401)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server response"
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            #if DEBUG
            let rawString = String(data: data, encoding: .utf8) ?? ""
            print("⚠️ [Network] Decoding Error: \(error)\nRaw Data: \(rawString)")
            #endif
            throw NetworkError.decodingFailed(error)
        }
    }
}
