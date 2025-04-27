//
//  Untitled.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//  Updated by Reza on 27.04.25.
//

import XCTest
import Combine
@testable import Coin64


class MockRepository: CoinRepositoryProtocol {
    var shouldRaiseError: Bool = false
    var mockCoinCurrentResponse: CoinCurrentResponse?
    var mockCoinDataResponse: CoinDataResponse?
    
    func fetchCurrent(instrumentType: InstrumentType, currency: Currency) -> AnyPublisher<CoinCurrentResponse, Error> {
        if shouldRaiseError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        } else if let response = mockCoinCurrentResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Empty(completeImmediately: true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchHistory(instrumentType: InstrumentType, dayLimit: Int, currency: Currency, dateTimeStamp: String?)  -> AnyPublisher<CoinDataResponse, Error> {
        
        if shouldRaiseError {
            return Fail(error: NSError(domain: "fetchHistory", code: 1001, userInfo: nil)).eraseToAnyPublisher()
                .eraseToAnyPublisher()
        } else if let response = mockCoinDataResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Empty(completeImmediately: true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
