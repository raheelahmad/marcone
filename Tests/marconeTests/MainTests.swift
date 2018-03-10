import PostgreSQL
import SWXMLHash
import XCTest

@testable import marconeLib

final class MainTests: XCTestCase {
    func testThings() {
        let urls = try? PodcastsController.allURLs()

        XCTAssertEqual(urls?.count, 3, "should have 0 count")
    }
}

