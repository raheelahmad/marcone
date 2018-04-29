import XCTest
@testable import AppTests

XCTMain([
    testCase(PodcastParsingTests.allTests),
    testCase(PodcastDBTests.allTests),
])
