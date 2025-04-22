//
//  ServiceProvider.swift
//  Coin64
//
//  Created by Reza on 21.04.25.
//
import Foundation

protocol CoinServiceProviderProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void)
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

    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = endpoint.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod

        session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(error ?? NetworkError.invalidResponse))
                return
            }

            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch(let error) {
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        .resume()
    }
}
