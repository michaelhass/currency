//
//  TestIntervalExtension.swift
//  CurrencyTests
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import XCTest
@testable import Currency

class TestIntervalExtension: XCTestCase {

    func testAge() throws {
        let maxAge: Int = 50
        let minutes: TimeInterval = 60

        let future = Date.distantFuture.timeIntervalSince1970
        XCTAssertFalse(future.isOlderThan(minutes: maxAge),
                       "Should return false for timestamps in the future")

        let referenceDate = Date.timeIntervalSinceReferenceDate
        XCTAssertTrue(referenceDate.isOlderThan(minutes: maxAge),
                      "Should return true for timestamp since reference date")

        let now = Date().timeIntervalSince1970
        XCTAssertFalse(now.isOlderThan(minutes: maxAge), "Should not be older for current time")

        let stillNot = Date().timeIntervalSince1970 - 49.9 * minutes
        XCTAssertFalse(stillNot.isOlderThan(minutes: maxAge))

        let bitOlder = Date().timeIntervalSince1970 - 50.1 * minutes
        XCTAssertTrue(bitOlder.isOlderThan(minutes: maxAge))
    }
}
