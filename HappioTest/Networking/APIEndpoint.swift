//
//  APIEndpoint.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

enum APIEndpoint {
    private static let baseURL = "https://api.themoviedb.org/3"

    case popularMovies(page: Int)
    case movieDetails(id: Int)

    var url: URL? {
        switch self {
        case .popularMovies(let page):
            var components = URLComponents(string: "\(APIEndpoint.baseURL)/movie/popular")
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)")
            ]
            return components?.url

        case .movieDetails(let id):
            return URL(string: "\(APIEndpoint.baseURL)/movie/\(id)")
        }
    }
}
