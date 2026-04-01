//
//  Movie.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?
    let voteAverage: Double
    let popularity: Double

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(AppConfig.imageBaseURL)\(path)")
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    var formattedReleaseYear: String {
        guard let date = releaseDate, date.count >= 4 else { return "N/A" }
        return String(date.prefix(4))
    }
}
