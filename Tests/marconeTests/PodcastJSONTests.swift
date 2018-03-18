//
//  PodcastJSONTests.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/17/18.
//

import XCTest

@testable import marconeLib

final class PodcastJSONTests: XCTestCase {
    private var podcast: Podcast!
    private var podcastJSON: [String: Any]!

    private let podcastURLString = "http://feeds.5by5.tv/asymcar"

    override func setUp() {
        let p = Podcast(id: 212, url: podcastURLString, allURLs: [], title: "A title", subtitle: "A subtitle", podcastDescription: "a description",
                        summary: "a summary", authorName: "an author", copyright: "a copyright",
                        imageURLStr: "some url string", categories: ["one", "two"], episodes: [],
                        averageDuration: 2122, episodesCount: 21, earliestPublishedDate: "some date", latestPublishedDate: "another date")
        podcastJSON = p.jsonWithoutEpisodes()
        podcast = p
    }

    func testId() {
        XCTAssertEqual(podcastJSON["id"] as? Int, podcast.id!)
    }
    func testTitle() {
        XCTAssertEqual(podcastJSON["title"] as? String, podcast.title)
    }
    func testURL() {
        XCTAssertEqual(podcastJSON["url"] as? String, podcast.url)
    }
    func testSubtitle() {
        XCTAssertEqual(podcastJSON["subtitle"] as? String, podcast.subtitle)
    }
    func testDescription() {
        XCTAssertEqual(podcastJSON["description"] as? String, podcast.podcastDescription)
    }
    func testSummary() {
        XCTAssertEqual(podcastJSON["summary"] as? String, podcast.summary)
    }
    func testAuthorName() {
        XCTAssertEqual(podcastJSON["author_name"] as? String, podcast.authorName)
    }
    func testImageURLString() {
        XCTAssertEqual(podcastJSON["image_url"] as? String, podcast.imageURLStr)
    }
    func testCategories() {
        XCTAssertEqual(podcastJSON["categories"] as? String, podcast.categories.joined(separator: ", "))
    }
    func testAverageDuration() {
        XCTAssertEqual(podcastJSON["average_duration"] as? Int, podcast.averageDuration)
    }
    func testEpisodesCount() {
        XCTAssertEqual(podcastJSON["episodes_count"] as? Int, podcast.episodesCount)
    }
    func testEarliestPublishedDate() {
        XCTAssertEqual(podcastJSON["earliest_published_date"] as? String, podcast.earliestPublishedDate)
    }
    func testLatestPublishedDate() {
        XCTAssertEqual(podcastJSON["latest_published_date"] as? String, podcast.latestPublishedDate)
    }
}

