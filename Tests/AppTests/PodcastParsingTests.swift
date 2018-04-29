import XCTest
import SWXMLHash

@testable import App

func parsedPodcast() -> Podcast? {
    return try? PodcastFetchController.parse(podcastStr: podcastToParseStr, feedURLStr: "http://www.gimletmedia.com/things.rss")
}

final class PodcastParsingTests: XCTestCase {
    static var allTests = [
        ("testParsing", testParsing),
    ]

    func testParsing() {
        let podcast = parsedPodcast()
        XCTAssertNotNil(podcast, "podcast should be parsed")
        XCTAssertEqual(podcast?.title, "Reply All")
        XCTAssertEqual(podcast?.episodes.count, 2)

        let episode = podcast?.episodes.first
        XCTAssertEqual(episode?.title, "#119 No More Safe Harbor")
    }

}

extension Podcast {
    init(title: String, url: String) {
        self.title = title
        self.url = url
        self.id = nil
        self.subtitle = nil
        self.podcastDescription = nil
        self.summary = nil
        self.allURLs = []
        self.authorName = nil
        self.copyright = nil
        self.imageURLStr = nil
        self.categories = []
        self.episodes = []
        self.averageDuration = 0
        self.episodesCount = 0
        self.earliestPublishedDate = nil
        self.latestPublishedDate = nil
    }
}

