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

extension String {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}

final class EpisodeFetchTests: XCTestCase {
    private var parsedPodcast: Podcast?
    private var firstEpisode: Episode?
    private let podcastURLString = "http://feeds.5by5.tv/asymcar"
    private let expectedDateStr = "Fri, 02 Mar 2018 00:00:00 GMT"

    override func setUp() {
        parsedPodcast = try? PodcastFetchController.podcast(fromString: testXML, podcastURLString: podcastURLString)
        firstEpisode = parsedPodcast?.episodes.first
    }

    func testTitle() { XCTAssertEqual(firstEpisode?.title, "42: The Empire Strikes Back", "has correct title") }
    func testGuid() { XCTAssertEqual(firstEpisode?.guid, "http://5by5.tv/asymcar/42", "has correct guid") }
    func testLink() { XCTAssertEqual(firstEpisode?.link, "http://5by5.tv/asymcar/42", "has correct link") }
    func testDescription() { XCTAssertEqual(firstEpisode?.episodeDescription?.trimmed, "We consider the news that BMW's i3 will revert to metal in its next iteration.  A question of business models engages much of our conversation, from optimized cars designed for transportation as a service to dynamic routes, pricing and arrival options.   Dyson's rumored auto ambitions divert our attention.  We close by musing on the utility of big data and the evolution of transportation.\n", "has correct description") }
    func testDuration() { XCTAssertEqual(firstEpisode?.duration, "1:17:30", "has correct duration") }
    func testAuthor() { XCTAssertEqual(firstEpisode?.author, "Horace Dediu & Jim Zellmer", "has correct author") }
    func testImageURL() { XCTAssertEqual(firstEpisode?.imageURL, "http://icebox.5by5.tv/images/broadcasts/92/cover.jpg") }
    func testKeywords() { XCTAssertEqual(firstEpisode!.keywords, "cars, automobile, automotive, driving, electric".components(separatedBy: ", ")) }
    func testEnclosureURL() { XCTAssertEqual(firstEpisode?.enclosureURL, "http://fdlyr.co/d/asymcar/cdn.5by5.tv/audio/broadcasts/asymcar/2018/asymcar-042.mp3", "has correct enclosure URL") }
    func testSummary() { XCTAssertEqual(firstEpisode?.summary?.trimmed, "We consider the news that BMW's i3 will revert to metal in its next iteration.  A question of business models engages much of our conversation, from optimized cars designed for transportation as a service to dynamic routes, pricing and arrival options.   Dyson's rumored auto ambitions divert our attention.  We close by musing on the utility of big data and the evolution of transportation.\n", "has correct summary") }
    func testDate() {
        let date = episodeDateFormatter.date(from: firstEpisode!.publicationDate!)
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let dateComps = cal.dateComponents([.month, .day, .year], from: date!)
        XCTAssertEqual(dateComps.day, 2, "has correct publication day")
        XCTAssertEqual(dateComps.month, 3, "has correct publication month")
        XCTAssertEqual(dateComps.year, 2018, "has correct publication year")
    }
}
