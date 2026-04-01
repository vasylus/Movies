//
//  MoviesCoordinator.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit
import SwiftUI

final class MoviesCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let dependencyContainer: AppDependencyContainer

    init(navigationController: UINavigationController, dependencyContainer: AppDependencyContainer) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }

    @MainActor func start() {
        showMoviesList()
    }

    @MainActor func showMoviesList() {
        let viewModel = dependencyContainer.makePopularMoviesViewModel()
        let viewController = MoviesListViewController(
            viewModel: viewModel,
            coordinator: self
        )
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showMovieDetail(movieId: Int) {
        let viewModel = dependencyContainer.makeMovieDetailViewModel(movieId: movieId)
        let detailView = MovieDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never
        hostingController.navigationItem.hidesBackButton = false
        navigationController.pushViewController(hostingController, animated: true)
    }
}
