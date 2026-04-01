//
//  NetworkError.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case noInternetConnection
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .noData:
            return "No data received from the server."
        case .decodingFailed(let error):
            return "Failed to parse server response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .noInternetConnection, .timeout, .serverError:
            return true
        default:
            return false
        }
    }
}
