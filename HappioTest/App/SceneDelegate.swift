//
//  SceneDelegate.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let dependencyContainer = AppDependencyContainer()
        let navigationController = UINavigationController()

        let appCoordinator = AppCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )

        self.window = window
        self.appCoordinator = appCoordinator

        appCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        if let urlContext = connectionOptions.urlContexts.first {
            _ = appCoordinator.handleDeepLink(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appCoordinator?.handleDeepLink(url)
    }
}
