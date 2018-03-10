//
//  LinuxMain.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/9/18.
//

import Foundation
#if os(Linux)

    import XCTest
    @testable import marconeTests

XCTMain([
    testCase(MainTests.allTests)
    ])

#endif

