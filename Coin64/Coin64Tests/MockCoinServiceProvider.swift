//
//  MockCoinServiceProvider.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//
import XCTest
@testable import Coin64

class MockCoinServiceProvider: CoinServiceProviderProtocol {
    var shouldFail: Bool = false
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "Customized Error", code: 0, userInfo: nil)))
        } else {
            if responseType == CoinData.self {
                completion(.success(CoinData(
                    data: [CoinInfo(timestamp: 1, type: "", market: "", instrument: "", open: 11, high: 12, low: 1, close: 1)],
                    error: nil) as! T)
                )
            } else if responseType == CoinCurrentData.self {
                do {
                    let coinCurrentData = try loadJSON("current_data", as: CoinCurrentData.self)
                    completion(.success(coinCurrentData as! T))
                } catch(let error) {
                    completion(.failure(error))
                }


            }

        }
    }

    func loadJSON<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw NSError(domain: "Missing file: \(filename).json", code: -1, userInfo: nil)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
