import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // For iOS 12 and below compatibility or if SceneDelegate is bypassed
        if #available(iOS 13.0, *) {
            // Managed by SceneDelegate
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let rootVC = CardDashboardViewController()
            let navVC = UINavigationController(rootViewController: rootVC)
            window.rootViewController = navVC
            self.window = window
            window.makeKeyAndVisible()
        }

        return true
    }

    
    
    
    // MARK: - UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}
