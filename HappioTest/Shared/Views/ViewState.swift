//
//  ViewState.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(NetworkError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }

    var error: NetworkError? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
