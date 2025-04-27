//
//  CoinDataResponseTests.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64


class CoinDataResponseTests: XCTestCase {
    
    func testCoinDataResponseCurrencySymbol() {
        [
            (given: "BTC-USD", expected: "$"),
            (given: "BTC-EUR", expected: "€"),
            (given: "BTC-GBP", expected: "£"),
            (given: "INVALID", expected: ""),
        ]
            .forEach {
                XCTAssertEqual(
                    CoinInfoResponse(timestamp: 1234567890, type: "type", market: "market", instrument: $0.given, open: 0, high: 0, low: 0, close: 0)
                        .currencySymbol,
                    $0.expected
                )
            }
    }
}
