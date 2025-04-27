//
//  CoinRepositoryTests.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//  Updated by Reza on 27.04.25.
//

import XCTest
import Combine
@testable import Coin64


class CoinRepositoryTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    var coinServiceProvider: MockCoinServiceProvider!
    var coinRepository: CoinRepository!
    
    override func setUp() {
        super.setUp()
        coinServiceProvider = MockCoinServiceProvider()
        coinRepository = CoinRepository(serviceProvider: coinServiceProvider)
        cancellables = []
    }
    
    override func tearDown() {
        coinServiceProvider = nil
        coinRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchHistorySuccess() {
        let expectation = self.expectation(description: "Fetch History Success")
        coinRepository.fetchHistory()
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    XCTFail("\(failure.localizedDescription)")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response.coinInfoResponses.count, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.timestamp, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.open, 11)
                XCTAssertEqual(response.coinInfoResponses.first?.high, 12)
                XCTAssertEqual(response.coinInfoResponses.first?.low, 1)
                XCTAssertEqual(response.coinInfoResponses.first?.close, 1)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
    
    func testFetchHistoryFailure() {
        coinServiceProvider.shouldFail = true
        let expectation = self.expectation(description: "Fetch History Failure")
        coinRepository.fetchCurrent(instrumentType: .btc)
            .receive(on: DispatchQueue.main)
            .sink( receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    XCTAssertEqual(failure.localizedDescription, "The operation couldn’t be completed. (Customized Error error 1000.)")
                    expectation.fulfill()
                }
            }, receiveValue: { result in
                XCTFail("Shouldn't reach here")
            })
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
    
    func testFetchCurrentSuccess() {
        let expectation = self.expectation(description: "Current Data loaded")
        coinRepository.fetchCurrent(instrumentType: .btc)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { response in
                XCTAssertEqual(response.currentValue, 77006.4085115704)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
    
    func testFetchCurrentFailure() {
        coinServiceProvider.shouldFail = true
        let expectation = self.expectation(description: "Current Data loaded")
        coinRepository.fetchCurrent(instrumentType: .btc)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error.localizedDescription,"The operation couldn’t be completed. (Customized Error error 1000.)")
                    expectation.fulfill()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
    
    func testFetchCurrentJsonFailure() {
        coinServiceProvider.jsonFileName = "invalidJson"
        let expectation = self.expectation(description: "Current Data loaded")
        coinRepository.fetchCurrent(instrumentType: .btc)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error.localizedDescription.contains("invalidJson.json"))
                    expectation.fulfill()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
    }
}
