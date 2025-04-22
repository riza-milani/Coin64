//
//  CoinRepositoryTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//

import XCTest
@testable import Coin64



class CoinRepositoryTests: XCTestCase {

    func testFetchHistorySuccess() {
        let coinServiceProvider = MockCoinServiceProvider()
        let coinRepository = CoinRepository(serviceProvider: coinServiceProvider)
        coinRepository.fetchHistory { reuslt in
            switch reuslt {
            case .success(let response):
                XCTAssertEqual(response.coinInfoResponses.count, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.timestamp, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.open, 11)
                XCTAssertEqual(response.coinInfoResponses.first?.high, 12)
                XCTAssertEqual(response.coinInfoResponses.first?.low, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.close, 1)

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testFetchHistoryFailure() {
        let coinServiceProvider = MockCoinServiceProvider()
        coinServiceProvider.shouldFail = true
        let coinRepository = CoinRepository(serviceProvider: coinServiceProvider)
        coinRepository.fetchCurrent(instrumentType: .btc, completeion: { result in
            switch result {
            case .success(_):
                XCTFail("Shouldn't reach here")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (Customized Error error 0.)")
            }
        })
    }

    func testFetchCurrentSuccess() {
        let coinServiceProvider = MockCoinServiceProvider()
        let coinRepository = CoinRepository(serviceProvider: coinServiceProvider)
        let expectation = self.expectation(description: "Current Data loaded")
        coinRepository.fetchCurrent(instrumentType: .btc, completeion: { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.currentValue, 77006.4085115704)
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        })
        waitForExpectations(timeout: 1)
    }



}
