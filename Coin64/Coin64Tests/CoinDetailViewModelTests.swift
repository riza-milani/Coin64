//
//  CoinDetailViewModelTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//

import XCTest
@testable import Coin64


class CoinDetailViewModelTests: XCTestCase {

    func testFormattedCurrentSuccess() {
        let mockRepository = MockRepository()
        let viewModel = CoinDetailViewModel(coinRepository: mockRepository, dateTimeStamp: "1744156800")
        XCTAssertEqual(viewModel.formattedCurrentDate(), "9. Apr 2025 at 02:00")

    }

    func testGetBTCCurrenciesSuccess() {
        let mockRepository = MockRepository()
        let viewModel = CoinDetailViewModel(coinRepository: mockRepository, dateTimeStamp: "1744156800")
        let expectation = self.expectation(description: "Currencies loaded")
        viewModel.getBTCCurrencies { response in
            XCTAssertEqual(response.count, 3, "Results should be 3 records")
            XCTAssertEqual(response.first?.close, 1000.0, "Close should be 1000.0")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
