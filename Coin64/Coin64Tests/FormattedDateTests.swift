//
//  String+formattedData.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//

import XCTest
@testable import Coin64


class StringFormattedDateTests: XCTestCase {

    func testFormattedDateWithValidTimestamp() {
        let timestampString = "1745318513" // 22. Apr 2025 at 12:41
        let date = Date(timeIntervalSince1970: 1745318513)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        let expectedFormattedDate = formatter.string(from: date)

        let result = timestampString.formattedDate

        XCTAssertEqual(result, expectedFormattedDate)
    }

    func testFormattedDateWithInvalidTimestamp() {
        let invalidTimestampString = "invalid"
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        let expectedFormattedDate = formatter.string(from: currentDate)

        let result = invalidTimestampString.formattedDate

        XCTAssertEqual(result, expectedFormattedDate)
    }
}
