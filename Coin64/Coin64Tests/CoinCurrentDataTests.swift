//
//  CoinCurrentDataTests.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64

class CoinCurrentDataTests: XCTestCase {

    func testExchangeDataDecodingSuccess() throws {
        let json = """
        {
            "Data": {
                "BTC-EUR": {
                    "VALUE": 12345.67,
                    "VALUE_LAST_UPDATE_TS": 1617181723
                }
            }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CoinCurrentData.self, from: json)

        XCTAssertEqual(decoded.exchange.pair, "BTC-EUR")
        XCTAssertEqual(decoded.exchange.currentValue, 12345.67)
        XCTAssertEqual(decoded.exchange.lastTimeStamp, 1617181723)
    }

    func testExchangeDataDecodingMissingDynamicKey() {
        let json = """
        {
            "Data": {}
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(CoinCurrentData.self, from: json)) { error in
            if case DecodingError.dataCorrupted(let context) = error {
                XCTAssertEqual(context.debugDescription, "Expected at least one key in the container.")
            } else {
                XCTFail("Expected dataCorrupted error, got: \(error)")
            }
        }
    }

    func testDynamicKeyInitWithIntValueReturnsNil() {
        let key = ExchangeData.DynamicKey(intValue: 42)
        XCTAssertNil(key, "DynamicKey should return nil when initialized with an integer value.")
    }

    func testExchangeDataDecodingMissingFields() {
        let json = """
        {
            "Data": {
                "BTC-EUR": {
                    "VALUE": 12345.67
                    // "VALUE_LAST_UPDATE_TS" is missing
                }
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(CoinCurrentData.self, from: json)) { error in
            print("Decoding failed as expected due to missing fields with error: \(error)")
        }
    }

    func testExchangeDataDecodingIncorrectDataTypes() {
        let json = """
        {
            "Data": {
                "BTC-EUR": {
                    "VALUE": "not-a-number",
                    "VALUE_LAST_UPDATE_TS": "not-an-int"
                }
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(CoinCurrentData.self, from: json)) { error in
            print("Decoding failed as expected due to incorrect data types with error: \(error)")
        }
    }

    func testExchangeDataDecodingMultiplePairs() throws {
        let json = """
        {
            "Data": {
                "BTC-EUR": {
                    "VALUE": 12345.67,
                    "VALUE_LAST_UPDATE_TS": 1617181723
                }
            }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CoinCurrentData.self, from: json)

        XCTAssertEqual(decoded.exchange.pair, "BTC-EUR")
        XCTAssertEqual(decoded.exchange.currentValue, 12345.67)
        XCTAssertEqual(decoded.exchange.lastTimeStamp, 1617181723)
    }

    func testDynamicKeyInitWithStringValueReturnsKey() {
        let key = ExchangeData.DynamicKey(stringValue: "BTC-USD")
        XCTAssertNotNil(key, "DynamicKey should not be nil when initialized with a string value.")
        XCTAssertEqual(key?.stringValue, "BTC-USD", "DynamicKey should have the correct string value.")
        XCTAssertNil(key?.intValue, "DynamicKey's intValue should be nil when initialized with a string.")
    }

    func testExchangeDataDecodingAdditionalFields() throws {
        let json = """
        {
            "Data": {
                "BTC-EUR": {
                    "VALUE": 12345.67,
                    "VALUE_LAST_UPDATE_TS": 1617181723,
                    "EXTRA_FIELD": "extra_value"
                }
            },
            "ExtraData": "should be ignored"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CoinCurrentData.self, from: json)

        XCTAssertEqual(decoded.exchange.pair, "BTC-EUR")
        XCTAssertEqual(decoded.exchange.currentValue, 12345.67)
        XCTAssertEqual(decoded.exchange.lastTimeStamp, 1617181723)
    }
}
