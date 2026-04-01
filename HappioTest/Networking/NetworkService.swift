//
//  NetworkService.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation


protocol NetworkServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MoviesResponse
    func fetchMovieDetails(id: Int) async throws -> MovieDetail
}

final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let apiKey: String
    private let decoder: JSONDecoder

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func fetchPopularMovies(page: Int) async throws -> MoviesResponse {
        guard let url = APIEndpoint.popularMovies(page: page).url else {
            throw NetworkError.invalidURL
        }
        return try await fetch(url: url)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetail {
        guard let url = APIEndpoint.movieDetails(id: id).url else {
            throw NetworkError.invalidURL
        }
        return try await fetch(url: url)
    }

    private func fetch<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw NetworkError.noData
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }

        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
