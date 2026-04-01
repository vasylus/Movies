//
//  AppDependencyContainer.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

protocol DependencyContainerProtocol {
    var networkService: NetworkServiceProtocol { get }
}

final class AppDependencyContainer: DependencyContainerProtocol {
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(apiKey: AppConfig.tmdbAPIKey)
    }()
    
    @MainActor func makePopularMoviesViewModel() -> MoviesListViewModel {
        MoviesListViewModel(networkService: networkService)
    }
    
    @MainActor func makeMovieDetailViewModel(movieId: Int) -> MovieDetailsViewModel {
        MovieDetailsViewModel(movieId: movieId, networkService: networkService)
    }
}
