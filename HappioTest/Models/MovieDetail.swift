//
//  MovieDetail.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let status: String?
    let tagline: String?

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(AppConfig.imageBaseURL)\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    var formattedRuntime: String {
        guard let runtime = runtime, runtime > 0 else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var formattedReleaseDate: String {
        guard let dateString = releaseDate else { return "N/A" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    var genreNames: String {
        genres.map(\.name).joined(separator: ", ")
    }
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}
