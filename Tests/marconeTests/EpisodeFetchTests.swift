//
//  EpisodeFetchTests.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/17/18.
//

import PostgreSQL
import SWXMLHash
import XCTest

@testable import marconeLib

final class EpisodeFetchTests: XCTestCase {
    private var parsedPodcast: Podcast?
    private var firstEpisode: Episode?
    private let podcastURLString = "http://feeds.5by5.tv/asymcar"

    override func setUp() {
        parsedPodcast = try? PodcastFetchController.podcast(fromString: testXML, podcastURLString: podcastURLString)
        firstEpisode = parsedPodcast?.episodes.first
        print(firstEpisode?.title)
    }

    func testHasCorrectTitle() { XCTAssertEqual(firstEpisode?.title, "42: The Empire Strikes Back", "has correct title") }
    func testHasCorrectGuid() { XCTAssertEqual(firstEpisode?.guid, "http://5by5.tv/asymcar/42", "has correct guid") }
    func testHasCorrectLink() { XCTAssertEqual(firstEpisode?.link, "http://5by5.tv/asymcar/42", "has correct link") }
    func testHasCorrectDescription() { XCTAssertEqual(firstEpisode?.episodeDescription?.trimmingCharacters(in: CharacterSet(charactersIn: " ")), "We consider the news that BMW's i3 will revert to metal in its next iteration.  A question of business models engages much of our conversation, from optimized cars designed for transportation as a service to dynamic routes, pricing and arrival options.   Dyson's rumored auto ambitions divert our attention.  We close by musing on the utility of big data and the evolution of transportation.\n", "has correct description") }
    func testHasCorrectEnclosureURL() { XCTAssertEqual(firstEpisode?.enclosureURL, "http://fdlyr.co/d/asymcar/cdn.5by5.tv/audio/broadcasts/asymcar/2018/asymcar-042.mp3", "has correct link") }
}
