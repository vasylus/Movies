//
//  ErrorView.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
