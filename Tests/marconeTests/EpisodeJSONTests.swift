//
//  episodeJSONTests.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/17/18.
//

import XCTest

@testable import marconeLib

final class EpisodeJSONTests: XCTestCase {
    private var episode: Episode!
    private var episodeJSON: [String: Any]!

    override func setUp() {
        let s = Episode(title: "a title", link: "a link", author: "an author", episodeDescription: "a description",
                        publicationDate: "Fri, 02 Mar 2018 00:00:00 GMT", guid: NSUUID().uuidString, imageURL: "some img url",
                        duration: 2122, enclosureType: "mpeg", enclosureLength: "21220", enclosureURL: "some url",
                        keywords: ["one", "two"], podcastId: 221)
        episode = s
        episodeJSON = s.json
    }

    func testId() {
        XCTAssertEqual(episodeJSON["guid"] as? String, episode.guid)
    }
    func testTitle() {
        XCTAssertEqual(episodeJSON["title"] as? String, episode.title)
    }
    func testURL() {
        XCTAssertEqual(episodeJSON["image_url"] as? String, episode.imageURL)
    }
    func testAuthor() {
        XCTAssertEqual(episodeJSON["author"] as? String, episode.author)
    }
    func testDuration() {
        XCTAssertEqual(episodeJSON["duration"] as? Int, episode.duration)
    }
    func testPublicationDate() {
        XCTAssertEqual(episodeJSON["pub_date"] as? String, episode.publicationDate)
    }
    func testKeywords() {
        XCTAssertEqual(episodeJSON["keywords"] as? String, episode.keywords.joined(separator: ", "))
    }
//    func testDescription() {
//        XCTAssertEqual(episodeJSON["description"] as? String, podcast.podcastDescription)
//    }
//    func testSummary() {
//        XCTAssertEqual(episodeJSON["summary"] as? String, podcast.summary)
//    }
//    func testAuthorName() {
//        XCTAssertEqual(episodeJSON["author_name"] as? String, podcast.authorName)
//    }
//    func testImageURLString() {
//        XCTAssertEqual(episodeJSON["image_url"] as? String, podcast.imageURLStr)
//    }
//    func testCategories() {
//        XCTAssertEqual(episodeJSON["categories"] as? String, podcast.categories.joined(separator: ", "))
//    }
}

