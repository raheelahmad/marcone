import PostgreSQL
import SWXMLHash
import XCTest

@testable import marconeLib

final class MainTests: XCTestCase {
    func testThings() {
        let podcast = Podcast.factory()
//        let episode1 = Episode.factory(podcastId: podcast.id!)
//        XCTAssertEqual(urls?.count, 3, "should have 0 count")
    }
}

extension Episode {
    static func factory(podcastId: Int, date: Date = Date()) -> Episode {
        return Episode(title: "Episode 1",
                       summary: "Summary",
                       episodeDescription: "Description",
                       publicationDate: Date().description,
                       guid: NSUUID().uuidString,
                       imageURL: nil,
                       duration: nil,
                       enclosureType: nil,
                       enclosureLength: nil,
                       enclosureURL: nil,
                       podcastId: podcastId)
    }
}

extension Podcast {
    static func factory(episodes: [Episode] = []) -> Podcast {
        return Podcast(id: NSUUID().uuidString,
                       url: "http://sakunlabs.com/p1",
                       allURLs: ["http://sakunlabs.com/p1"],
                       title: "Podcast 1",
                       subtitle: "Subtitle for Podcast 1",
                       podcastDescription: nil,
                       summary: "Summary for Podcast 1",
                       authorName: "Some author",
                       copyright: nil, imageURLStr: nil, categories: [],
                       episodes: episodes)
    }
}
