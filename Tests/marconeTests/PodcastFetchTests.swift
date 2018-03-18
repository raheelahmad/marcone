//
//  PodcastFetchTests.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/17/18.
//

import PostgreSQL
import SWXMLHash
import XCTest

@testable import marconeLib

final class PodcastFetchTests: XCTestCase {
    private var parsedPodcast: Podcast?
    private let podcastURLString = "http://feeds.5by5.tv/asymcar"

    override func setUp() {
        parsedPodcast = try? PodcastFetchController.podcast(fromString: testXML, podcastURLString: podcastURLString)
    }

    func testWasAbleToParse() { XCTAssertNotNil(parsedPodcast, "Should be able to parse a real XML") }
    func testHasNoId() { XCTAssertNil(parsedPodcast?.id, "Should not have an id when parsing from XML") }
    func testTitle() { XCTAssertEqual(parsedPodcast?.title, "Asymcar", "Should have correct title") }
    func testNumberOfEpisodes() { XCTAssertEqual(parsedPodcast?.episodes.count, 41, "Should have correct number of episodes") }
    func testURL() { XCTAssertEqual(parsedPodcast?.url, podcastURLString, "Should have correct url") }
    func testSubtitle() { XCTAssertEqual(parsedPodcast?.subtitle, "Asymcar", "Should have correct url") }
    func testSummary() { XCTAssertEqual(parsedPodcast?.summary, "Horace Dediu and Jim Zellmer discuss the politics, processes and possibilities of cars in light of: 1. Young people deferring drivers licenses.  2. The growth of car sharing.  3. Practical alternative power trains.  4. Urbanization. 5. Increased Congestion.  6. Driverless cars. 7. Rise of the \"App Economy\". Hosted by Horace Dediu & Jim Zellmer.", "Should have correct summary") }
    func testDescription() { XCTAssertEqual(parsedPodcast?.podcastDescription, "Horace Dediu and Jim Zellmer discuss the politics, processes and possibilities of cars in light of: 1. Young people deferring drivers licenses.  2. The growth of car sharing.  3. Practical alternative power trains.  4. Urbanization. 5. Increased Congestion.  6. Driverless cars. 7. Rise of the \"App Economy\". Hosted by Horace Dediu & Jim Zellmer.", "Should have correct description") }
    func testAuthorName() { XCTAssertEqual(parsedPodcast?.authorName, "5by5", "Should have correct author name") }
    func testImageURL() { XCTAssertEqual(parsedPodcast?.imageURLStr, "http://icebox.5by5.tv/images/broadcasts/92/cover.jpg", "Should have correct image URL") }
    func testCategories() { XCTAssertEqual(Set(parsedPodcast!.categories), ["Management & Marketing", "Business", "Technology", "Tech News"], "Should have correct categories") }

}
