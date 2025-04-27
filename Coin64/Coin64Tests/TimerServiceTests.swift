//
//  TimerServiceTests.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64



class TimerServiceTests: XCTestCase {
    

    var timerService: TimerService!

    override func setUp() {
        super.setUp()
        timerService = TimerService()
    }

    override func tearDown() {
        timerService = nil
        super.tearDown()
    }

    func testStartTimer() {
        let expectation = self.expectation(description: "Start Timer")
        timerService.startTimer(interval: 1, repeats: false) {
            XCTAssertTrue(true)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testInvalidateTimer() {
        let expectation = self.expectation(description: "Start Timer")
        timerService.startTimer(interval: 1, repeats: false) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        timerService.invalidate()
        XCTAssertNil(timerService.timerPublisher)
    }
    
    func testStartTimerRepeatsMultipleTimes() {
        let expectation = self.expectation(description: "Timer handler called multiple times")
        expectation.expectedFulfillmentCount = 3
        
        var callCount = 0

        timerService.startTimer(interval: 0.1, repeats: true) {
            callCount += 1
            expectation.fulfill()
            
            if callCount == 3 {
                self.timerService.invalidate() // Stop after 3 triggers
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
