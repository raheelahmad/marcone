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
    func testHasCorrectTitle() { XCTAssertEqual(parsedPodcast?.title, "Asymcar", "Should have correct title") }
    func testHasCorrectNumberOfEpisodes() { XCTAssertEqual(parsedPodcast?.episodes.count, 41, "Should have correct number of episodes") }
    func testHasCorrectURL() { XCTAssertEqual(parsedPodcast?.url, podcastURLString, "Should have correct url") }
    func testHasCorrectSubtitle() { XCTAssertEqual(parsedPodcast?.subtitle, "Asymcar", "Should have correct url") }
    func testHasCorrectSummary() { XCTAssertEqual(parsedPodcast?.summary, "Horace Dediu and Jim Zellmer discuss the politics, processes and possibilities of cars in light of: 1. Young people deferring drivers licenses.  2. The growth of car sharing.  3. Practical alternative power trains.  4. Urbanization. 5. Increased Congestion.  6. Driverless cars. 7. Rise of the \"App Economy\". Hosted by Horace Dediu & Jim Zellmer.", "Should have correct summary") }
    func testHasCorrectDescription() { XCTAssertEqual(parsedPodcast?.podcastDescription, "Horace Dediu and Jim Zellmer discuss the politics, processes and possibilities of cars in light of: 1. Young people deferring drivers licenses.  2. The growth of car sharing.  3. Practical alternative power trains.  4. Urbanization. 5. Increased Congestion.  6. Driverless cars. 7. Rise of the \"App Economy\". Hosted by Horace Dediu & Jim Zellmer.", "Should have correct description") }
    func testHasCorrectAuthorName() { XCTAssertEqual(parsedPodcast?.authorName, "5by5", "Should have correct author name") }
    func testHasCorrectImageURL() { XCTAssertEqual(parsedPodcast?.imageURLStr, "http://icebox.5by5.tv/images/broadcasts/92/cover.jpg", "Should have correct image URL") }
    func testHasCorrectCategories() { XCTAssertEqual(Set(parsedPodcast!.categories), ["Management & Marketing", "Business", "Technology", "Tech News"], "Should have correct categories") }

}
