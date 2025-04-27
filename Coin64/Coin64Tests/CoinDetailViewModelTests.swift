//
//  CoinDetailViewModelTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//  Updated by Reza on 27.04.25.
//

import XCTest
import Combine
@testable import Coin64


class CoinDetailViewModelTests: XCTestCase {
    
    var viewModel: CoinDetailViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockRepository: MockRepository!
    let coinData = [CoinInfo(timestamp: 1744156800, type: "986", market: "cadli", instrument: "BTC-EUR", open: 1000.0, high: 1000.0, low: 800.0, close: 1000.0)]
    
    override func setUp() {
        super.setUp()
        mockRepository = MockRepository()
        viewModel = CoinDetailViewModel(coinRepository: mockRepository, dateTimeStamp: "1744156800")
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testGetBTCCurrenciesSuccess() {
        let expectation = self.expectation(description: "Currencies loaded")
        mockRepository.mockCoinDataResponse = CoinDataResponse(coinData: CoinData(data: coinData , error: nil))
        viewModel.$coinInfoResponses
            .dropFirst()
            .sink(receiveValue: { response in
                XCTAssertEqual(response.count, 3, "Results should be 3 records")
                XCTAssertEqual(response.first?.close, 1000.0, "Close should be 1000.0")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        viewModel.getBTCCurrencies()
        waitForExpectations(timeout: 1)
    }
    
    func testIsLoading() {
        let expectation = self.expectation(description: "Currencies loaded")
        viewModel.$isLoading
            .dropFirst()
            .sink(receiveValue: { response in
                XCTAssertEqual(response, true, "isLoading should be true")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        viewModel.getBTCCurrencies()
        waitForExpectations(timeout: 1)
    }
    
    func testErrorMessageShown() {
        mockRepository.shouldRaiseError = true
        mockRepository.mockCoinDataResponse = CoinDataResponse(coinData: CoinData(data: coinData , error: nil))
        let viewModel = CoinDetailViewModel(coinRepository: mockRepository, dateTimeStamp: "")
        let expectation = self.expectation(description: "Currencies loaded")
        viewModel.$errorMessage
            .dropFirst()
            .sink(receiveValue: { response in
                XCTAssertEqual(response, "The operation couldn’t be completed. (fetchHistory error 1001.)")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        viewModel.getBTCCurrencies()
        waitForExpectations(timeout: 1)
    }
}

