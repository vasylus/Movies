//
//  MovieDetailsViewModel.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import Foundation
import Combine

@MainActor
final class MovieDetailsViewModel: ObservableObject {

    @Published private(set) var movie: MovieDetail?
    @Published private(set) var state: DetailViewState = .loading

    enum DetailViewState: Equatable {
        case loading
        case success
        case failure(String)

        static func == (lhs: DetailViewState, rhs: DetailViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.success, .success): return true
            case (.failure(let a), .failure(let b)): return a == b
            default: return false
            }
        }
    }

    let movieId: Int
    private let networkService: NetworkServiceProtocol

    init(movieId: Int, networkService: NetworkServiceProtocol) {
        self.movieId = movieId
        self.networkService = networkService
    }

    func fetchMovieDetails() async {
        state = .loading
        do {
            let detail = try await networkService.fetchMovieDetails(id: movieId)
            movie = detail
            state = .success
        } catch let error as NetworkError {
            state = .failure(error.errorDescription ?? "Unknown error")
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func retry() async {
        await fetchMovieDetails()
    }
}
