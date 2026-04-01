//
//  MovieDetailsView.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import SwiftUI

struct MovieDetailsView: View {
    
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
                
            case .success:
                if let movie = viewModel.movie {
                    MovieDetailContentView(movie: movie)
                }
                
            case .failure(let message):
                ErrorView(message: message) {
                    Task { await viewModel.retry() }
                }
            }
        }
        .navigationTitle(viewModel.movie?.title ?? "Movie Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMovieDetails()
        }
    }
}
