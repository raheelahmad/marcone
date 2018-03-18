//
//  IntDurationTests.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/17/18.
//

import Foundation
import XCTest

@testable import marconeLib

final class IntDurationTests: XCTestCase {
    func testNonNumString() {
        XCTAssertNil("hello".asDurationInt)
    }
    func testOneInt() {
        XCTAssertEqual("20".asDurationInt, 20)
    }
    func testTwoInts() {
        XCTAssertEqual("10:20".asDurationInt, 620)
    }
    func testThreeInts() {
        XCTAssertEqual("2:10:20".asDurationInt, 7820)
    }
}
