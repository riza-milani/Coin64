//
//  EndpointTests.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64


class EndpointTests: XCTestCase {

    func testCurrentEndpoint() {
        let url = Endpoint.current(BaseURL.production, .btc, .eur).url
        let expectedURL = URL(string: "https://data-api.coindesk.com/index/cc/v1/latest/tick?market=cadli&instruments=BTC-EUR&apply_mapping=true")
        XCTAssertEqual(url, expectedURL)
    }

    func testHistoryEndpoint() {
        let url = Endpoint.historical(.production, .btc, .eur, daysLimit: 0, dateTimeStamp: "123456").url
        let expectedURL = URL(string: "https://data-api.coindesk.com/index/cc/v1/historical/days?market=cadli&instrument=BTC-EUR&limit=0&aggregate=1&fill=true&apply_mapping=true&response_format=JSON&to_ts=123456")
        XCTAssertEqual(url, expectedURL)
    }
}
