//
//  CoinListViewModelTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//  Updated by Reza on 27.04.25.
//

import XCTest
import Combine
@testable import Coin64


class CoinListViewModelTests: XCTestCase {
    
    var viewModel: CoinListViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockRepository: MockRepository!
    var mockTimerService: MockTimerService!
    var coinData: [CoinInfo]!
    
    override func setUp() {
        super.setUp()
        coinData = [CoinInfo(timestamp: 1744156800, type: "986", market: "cadli", instrument: "BTC-EUR", open: 1000.0, high: 1000.0, low: 800.0, close: 1000.0)]
        mockRepository = MockRepository()
        mockTimerService = MockTimerService()
        viewModel = CoinListViewModel(coinRepository: mockRepository, timerService: mockTimerService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockTimerService = nil
        mockRepository = nil
        cancellables = nil
        coinData = nil
        super.tearDown()
    }
    
    func testGetBTCHistorySuccess() {
        let expectation = self.expectation(description: "History loaded")
        mockRepository.mockCoinDataResponse = CoinDataResponse(coinData: CoinData(data: coinData , error: nil))
        viewModel.$sortedCoinDataResponse
            .dropFirst()
            .sink { responses in
                XCTAssertFalse(responses.isEmpty || responses.count == 0, "Should load responses")
                XCTAssertEqual(responses.first?.timestamp, 1744156800, "TimeStamp should be 1744156800")
                XCTAssertEqual(responses.first?.low, 800.0, "low should be 800.0")
                expectation.fulfill()
            }.store(in: &cancellables)
        viewModel.getBTCHistory()
        waitForExpectations(timeout: 1)
    }
    
    func testGetBTCHistoryFailure() {
        let expectation = self.expectation(description: "Failure path")
        mockRepository.shouldRaiseError = true
        
        viewModel.getBTCHistory()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.errorMessage)
            XCTAssertNotNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetLatestBTCSuccess() {
        let expectation = self.expectation(description: "Success")
        let mockData = CoinCurrentResponse(currentValue: 50000.0, lastTimeStamp: 1744156801)
        let coinInfoResponse = CoinInfoResponse(timestamp: 1001, type: "123", market: "m1", instrument: "BTC-EUR", open: 1000, high: 1002, low: 999, close: 1001)
        mockRepository.mockCoinCurrentResponse = mockData
        viewModel.sortedCoinDataResponse = [coinInfoResponse]
        
        viewModel.getLatestBTC()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.sortedCoinDataResponse.first?.timestamp, mockData.lastTimeStamp)
            XCTAssertEqual(self.viewModel.sortedCoinDataResponse.first?.close, mockData.currentValue)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetLatestBTCFailure() {
        let expectation = self.expectation(description: "Failure")
        mockRepository.shouldRaiseError = true
        
        viewModel.getLatestBTC()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSetTimerSuccess() {
        let expectation = self.expectation(description: "Failure path")
        mockRepository.mockCoinDataResponse = CoinDataResponse(coinData: CoinData(data: coinData , error: nil))
        
        viewModel.getBTCHistory()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testSetupRefreshTimerIsCalledSuccess() {
        let expectation = self.expectation(description: "Refresh Timer Success")
        mockRepository.mockCoinDataResponse = CoinDataResponse(coinData: CoinData(data: coinData , error: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockTimerService.startTimerCalled)
            expectation.fulfill()
        }
        
        viewModel.getBTCHistory()
        wait(for: [expectation], timeout: 1)
    }
    
    func testSetupRefreshTimerIsCalledFailure() {
        let expectation = self.expectation(description: "Refresh Timer Failure")
        mockRepository.mockCoinDataResponse = nil
        // Or alternativly we can raise an error. I've already use a lot of raise errors, so I chose empty data instead
        //mockRepository.shouldRaiseError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.mockTimerService.startTimerCalled)
            expectation.fulfill()
        }
        viewModel.getBTCHistory()
        wait(for: [expectation], timeout: 1)
    }
    
    func testSetTimerFailure() {
        let expectation = self.expectation(description: "Failure path")
        mockRepository.shouldRaiseError = true
        
        viewModel.getBTCHistory()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testMakeCoinDetailViewModel() {
        XCTAssertNotNil(viewModel.makeCoinDetailViewModel(dateTimeStamp: 1744156801))
    }
}

