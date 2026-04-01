//
//  LoadingView.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 01.04.2026.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
