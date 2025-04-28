//
//  ServiceProvider.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//  Updated by Reza on 27.04.25.
//

import Foundation
import Combine

protocol CoinServiceProviderProtocol {
    func request<T: Decodable>(_ endpoint: EndpointProtocol, responseType: T.Type) -> AnyPublisher<T, Error>
}

class CoinServiceProvider: CoinServiceProviderProtocol {
    enum NetworkError: Error {
        case invalidURL
        case noInternetConnection
        case invalidResponse
        case invalidStatusCode(Int)
        case decodingError(Error)
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: EndpointProtocol, responseType: T.Type) -> AnyPublisher<T, Error> {
        guard let url = endpoint.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidStatusCode(response.statusCode)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                if let networkError = error as? URLError, networkError.code == .notConnectedToInternet {
                    return NetworkError.noInternetConnection
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return error
                }
            }
            .eraseToAnyPublisher()
    }
}

//MARK: - Localized errors
extension CoinServiceProvider.NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "The URL provided is invalid.", comment: "Invalid URL error")
        case .noInternetConnection:
            return String(localized: "No internet connection is available.", comment: "No internet connection error")
        case .invalidResponse:
            return String(localized: "The server response was invalid.", comment: "Invalid server response error")
        case .invalidStatusCode(let code):
            return String(localized: "Received HTTP status code \(code).", comment: "Invalid HTTP status code error")
        case .decodingError(let error):
            return String(localized: "Failed to decode the response: \(error.localizedDescription)", comment: "Decoding error")
        }
    }
}

// MARK: - Used in Unit-Testing
extension CoinServiceProvider.NetworkError: Equatable {
    static func == (lhs: CoinServiceProvider.NetworkError, rhs: CoinServiceProvider.NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.noInternetConnection, .noInternetConnection),
            (.invalidResponse, .invalidResponse),
            (.decodingError, .decodingError):
            return true
        case let (.invalidStatusCode(lhsCode), .invalidStatusCode(rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
