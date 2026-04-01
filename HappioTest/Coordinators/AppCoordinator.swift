//
//  AppCoordinator.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let dependencyContainer: AppDependencyContainer
    
    init(navigationController: UINavigationController, dependencyContainer: AppDependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        
        setupNavigationBarAppearance()
    }
    
    func start() {
        let moviesCoordinator = MoviesCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        addChild(moviesCoordinator)
        moviesCoordinator.start()
    }
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == AppConfig.deepLinkScheme,
              url.host == AppConfig.deepLinkMovieDetailsHost,
              let movieIdString = url.pathComponents.dropFirst().first,
              let movieId = Int(movieIdString) else {
            print("Invalid deep link url: \(url.absoluteString)")
            return
        }
        
        navigateToMovieDetail(movieId: movieId)
    }
    
    private func navigateToMovieDetail(movieId: Int) {
        guard let moviesCoordinator = childCoordinators.first(
            where: { $0 is MoviesCoordinator }
        ) as? MoviesCoordinator else {
            return
        }
        
        navigationController.popToRootViewController(animated: false)
        moviesCoordinator.showMovieDetail(movieId: movieId)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        UINavigationBar.appearance().prefersLargeTitles = true
    }
}
