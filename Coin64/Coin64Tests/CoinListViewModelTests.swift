//
//  CoinListViewModelTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//

import XCTest
@testable import Coin64


class CoinListViewModelTests: XCTestCase {

    func testGetBTCHistorySuccess() {
        let mockRepository = MockRepository()
        let viewModel = CoinListViewModel(coinRepository: mockRepository)

        let expectation = self.expectation(description: "History loaded")
        viewModel.getBTCHistory { responses in
            XCTAssertFalse(responses.isEmpty || responses.count == 0, "Should load responses")
            XCTAssertEqual(responses.first?.timestamp, 1744156800, "TimeStamp should be 1744156800")
            XCTAssertEqual(responses.first?.low, 800.0, "low should be 800.0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetBTCHistoryFailure() {
        let mockRepository = MockRepository()
        mockRepository.shouldRaiseError = true
        let viewModel = CoinListViewModel(coinRepository: mockRepository)

        let expectation = self.expectation(description: "History loaded")
        viewModel.getBTCHistory { responses in
            print(responses)
            XCTAssertTrue(responses.isEmpty && responses.count == 0, "Should load responses")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGetLatestBTCSuccess() {
        let mockRepository = MockRepository()
        let viewModel = CoinListViewModel(coinRepository: mockRepository)
        let expectation = self.expectation(description: "History and Latest loaded")
        viewModel.getBTCHistory { _ in
            viewModel.getLatestBTC {
                XCTAssertEqual(viewModel.sortedCoinDataResponse[0].close, 2000, "price should be 2000")
                XCTAssertEqual(viewModel.sortedCoinDataResponse[0].timestamp, 1744156801, "timeStamo should be 1744156801")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testGetLatestBTCFailure() {
        let mockRepository = MockRepository()
        mockRepository.shouldRaiseError = true
        let viewModel = CoinListViewModel(coinRepository: mockRepository)
        let expectation = self.expectation(description: "History and Latest loaded")
        viewModel.getBTCHistory { _ in
            viewModel.getLatestBTC {
                XCTAssertTrue(viewModel.sortedCoinDataResponse.isEmpty, "Should load responses")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
