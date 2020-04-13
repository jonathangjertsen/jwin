import UIKit
import SwiftUI

/// Parameters to control how often to back up the state to disk
private let saveIntervalS = 10.0
private let saveToleranceFraction = 0.2

/// Sets up everything the app needs and creates a view
/// - Returns: The top-level SwiftUI View for the app
func startApp() -> AppView {
    /// Load app state
    let (appState, url) = AppState.loadFromDefaultOrDemo()

    /// Initialize the view
    let view = AppView(
        appState: appState,
        appStateUrl: url,
        lastStateSave: DatePoke()
    )

    /// Set up a timer to save the state to disk every 10-15 s
    _ = appState.saveToDefaultUrlEvery(
        n: saveIntervalS,
        toleranceFraction: saveToleranceFraction,
        onSuccess: { _ in view.saveSuccess() },
        onError: { _ in view.saveFail() }
    )

    return view
}

// MARK: -boilerplate generated by the project wizard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration { UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role) }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: startApp())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
