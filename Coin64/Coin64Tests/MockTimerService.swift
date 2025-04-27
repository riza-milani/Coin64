//
//  MockRefreshTimer.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64


class MockTimerService: TimerServiceProtocol {
    var startTimerCalled = false
    var invalidateCalled = false

    func startTimer(interval: TimeInterval, repeats: Bool, handler: @escaping () -> Void) {
        startTimerCalled = true
        handler()
    }

    func invalidate() {
        invalidateCalled = true
    }
}
