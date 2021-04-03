// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = HomeView(
            store: Store(
                initialState: HomeState(),
                reducer: homeReducer,
                environment: HomeEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                ))
        )
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
