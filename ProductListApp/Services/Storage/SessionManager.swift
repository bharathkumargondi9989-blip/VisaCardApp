import Foundation

/// Session manager maintaining auth token, user session, and sync state
final class SessionManager {
    static let shared = SessionManager()

    private let tokenKey = "com.productlistapp.jwtToken"
    private let usernameKey = "com.productlistapp.username"

    private let userDefaults = UserDefaults.standard

    var jwtToken: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.setValue(newValue, forKey: tokenKey)
        }
    }

    var username: String {
        get {
            return userDefaults.string(forKey: usernameKey) ?? "sjqa-divya"
        }
        set {
            userDefaults.setValue(newValue, forKey: usernameKey)
        }
    }

    var isAuthenticated: Bool {
        guard let token = jwtToken, !token.isEmpty else { return false }
        return true
    }

    private init() {}

    func clearSession() {
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: usernameKey)
    }
}
