import PostgreSQL
import SWXMLHash
import XCTest

@testable import marconeLib

final class SampleTests: XCTestCase {
    func testThings() {
        let urls = try? PodcastsController.allURLs()

        XCTAssertEqual(urls?.count, 3, "should have 0 count")
    }
}

