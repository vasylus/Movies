//
//  MoviesListViewModel.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation
import Combine

@MainActor
final class MoviesListViewModel: ObservableObject {

    @Published private(set) var movies: [Movie] = []
    @Published private(set) var state: ViewState<[Movie]> = .idle
    @Published private(set) var isLoadingMore: Bool = false

    private let networkService: NetworkServiceProtocol
    private var currentPage = 1
    private var totalPages = 1
    private var fetchTask: Task<Void, Never>?

    var canLoadMore: Bool {
        currentPage < totalPages && !isLoadingMore
    }

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchPopularMovies() {
        guard !state.isLoading else { return }

        fetchTask?.cancel()
        fetchTask = Task {
            await performFetch(page: 1, isRefresh: true)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        let threshold = movies.count - 5
        guard currentIndex >= threshold, canLoadMore, !isLoadingMore else { return }

        Task {
            await loadNextPage()
        }
    }

    func retry() {
        fetchPopularMovies()
    }

    private func performFetch(page: Int, isRefresh: Bool) async {
        if isRefresh {
            state = .loading
            currentPage = 1
            movies = []
        } else {
            isLoadingMore = true
        }

        do {
            let response = try await networkService.fetchPopularMovies(page: page)

            guard !Task.isCancelled else { return }

            totalPages = response.totalPages
            currentPage = page

            if isRefresh {
                movies = response.results
            } else {
                let existingIds = Set(movies.map(\.id))
                let newMovies = response.results.filter { !existingIds.contains($0.id) }
                movies += newMovies
            }

            state = .success(movies)
        } catch let error as NetworkError {
            guard !Task.isCancelled else { return }
            if isRefresh {
                state = .failure(error)
            }
        } catch {
            guard !Task.isCancelled else { return }
            if isRefresh {
                state = .failure(.unknown(error))
            }
        }

        isLoadingMore = false
    }

    private func loadNextPage() async {
        await performFetch(page: currentPage + 1, isRefresh: false)
    }
}
