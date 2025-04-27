//
//  TimerService.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//
import Foundation
import Combine

protocol TimerServiceProtocol {
    func startTimer(interval: TimeInterval, repeats: Bool, handler: @escaping () -> Void)
    func invalidate()
}

class TimerService: TimerServiceProtocol {
    private(set) var timerPublisher: AnyCancellable?

    func startTimer(interval: TimeInterval, repeats: Bool, handler: @escaping () -> Void) {
        timerPublisher?.cancel()

        if repeats {
            timerPublisher = Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    handler()
                }
        } else {
            timerPublisher = Just(())
                .delay(for: .seconds(interval), scheduler: RunLoop.main)
                .sink { _ in
                    handler()
                    self.timerPublisher?.cancel()
                    self.timerPublisher = nil
                }
        }
    }

    func invalidate() {
        timerPublisher?.cancel()
        timerPublisher = nil
    }

    deinit {
        invalidate()
    }
}
