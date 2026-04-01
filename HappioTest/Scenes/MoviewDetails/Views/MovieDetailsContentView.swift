//
//  MovieDetailsContentView.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import SwiftUI

struct MovieDetailContentView: View {
    
    let movie: MovieDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                PosterHeaderView(movie: movie)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let tagline = movie.tagline, !tagline.isEmpty {
                            Text(tagline)
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    MovieInfoRowView(movie: movie)
                    
                    Divider()
                    
                    if !movie.overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(movie.overview)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if !movie.genres.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Genres")
                                .font(.headline)
                                .foregroundColor(.primary)
                            GenreTagsView(genres: movie.genres)
                        }
                    }
                    
                    MovieAdditionalInfoView(movie: movie)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MovieInfoRowView: View {
    let movie: MovieDetail
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            InfoBadge(
                icon: "star.fill",
                iconColor: .orange,
                value: movie.formattedRating,
                label: "Rating"
            )
            .frame(maxWidth: .infinity)
            
            Divider().frame(height: 40)
            
            InfoBadge(
                icon: "calendar",
                iconColor: .blue,
                value: movie.formattedReleaseDate,
                label: "Released"
            )
            .frame(maxWidth: .infinity)
            
            Divider().frame(height: 40)
            
            InfoBadge(
                icon: "clock",
                iconColor: .green,
                value: movie.formattedRuntime,
                label: "Runtime"
            )
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct InfoBadge: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private struct GenreTagsView: View {
    let genres: [Genre]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(genres) { genre in
                    TagView(text: genre.name)
                }
            }
            .padding(.horizontal, 1)
        }
    }
}

private struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.12))
            .foregroundColor(.accentColor)
            .cornerRadius(20)
    }
}

private struct MovieAdditionalInfoView: View {
    let movie: MovieDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            if let status = movie.status {
                DetailRow(label: "Status", value: status)
            }
            DetailRow(label: "Vote Count", value: "\(movie.voteCount) votes")
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
