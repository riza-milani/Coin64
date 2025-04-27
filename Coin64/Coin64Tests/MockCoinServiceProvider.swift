//
//  MockCoinServiceProvider.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//  Updated by Reza on 27.04.25.
//

import XCTest
import Combine
@testable import Coin64


class MockCoinServiceProvider: CoinServiceProviderProtocol {
    var shouldFail: Bool = false
    var isValidURL: Bool = true
    var jsonFileName: String = "current_data"
    
    func request<T: Decodable>(_ endpoint: EndpointProtocol, responseType: T.Type) -> AnyPublisher<T, Error> {
        if !shouldFail {
            if responseType == CoinData.self {
                let coinData = CoinData(
                    data: [CoinInfo(timestamp: 1, type: "", market: "", instrument: "", open: 11, high: 12, low: 1, close: 1)],
                    error: nil) as! T
                return Just(coinData).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else if responseType == CoinCurrentData.self {
                do {
                    let coinCurrentData = try loadJSON(jsonFileName, as: CoinCurrentData.self)
                    return Just(coinCurrentData as! T).setFailureType(to: Error.self).eraseToAnyPublisher()
                } catch(let error) {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
        }
        return Fail(error: NSError(domain: "Customized Error", code: 1000, userInfo: nil)).eraseToAnyPublisher()
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
