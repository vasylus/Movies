//
//  PosterHeaderView.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import SwiftUI

struct PosterHeaderView: View {
    let movie: MovieDetail
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            posterFallback
                        }
                    }
                    .frame(width: geo.size.width, height: 280)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    )
                } else {
                    posterFallback
                        .frame(width: geo.size.width, height: 280)
                }
                
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Color(.secondarySystemBackground)
                        }
                    }
                    .frame(width: 90, height: 135)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 8)
                    .padding(.leading, 20)
                    .padding(.bottom, -20)
                }
            }
            .frame(width: geo.size.width, height: 280)
            .clipped()
        }
        .frame(height: 280)
    }
    
    private var posterFallback: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .overlay(
                Image(systemName: "film")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
            )
    }
}
