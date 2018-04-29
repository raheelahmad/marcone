//
//  PodcastDBTests.swift
//  AppTests
//
//  Created by Raheel Ahmad on 4/26/18.
//

import Foundation
import XCTest
import Vapor
import PostgreSQL
@testable import App

final class PodcastDBTests: XCTestCase {
    static var allTests = [
        ("testInsert", testInsert),
        ("testPodcastDBDeserialization", testPodcastDBDeserialization),
    ]

    func testPodcastDBDeserialization() {
        do {
            let podcast = parsedPodcast()!
            let connection = try getConnection()

            try deleteExisting(podcast: podcast, connection: connection)
            let podcastId = try PodcastDBController.insert(db: connection, podcast: podcast).wait()

            XCTAssertNotNil(podcastId)
            let insertedPodcast = try PodcastDBController.podcast(forId: podcastId!, connection: connection).wait()
            XCTAssertEqual(podcastId, insertedPodcast.id)
            XCTAssertEqual(podcast.title, insertedPodcast.title)
            XCTAssertEqual(podcast.url, insertedPodcast.url)
            XCTAssertEqual(podcast.subtitle, insertedPodcast.subtitle)
            XCTAssertEqual(podcast.allURLs, insertedPodcast.allURLs)
            XCTAssertEqual(podcast.podcastDescription, insertedPodcast.podcastDescription)
            XCTAssertEqual(podcast.summary, insertedPodcast.summary)
            XCTAssertEqual(podcast.authorName, insertedPodcast.authorName)
            XCTAssertEqual(podcast.copyright, insertedPodcast.copyright)
            XCTAssertEqual(podcast.imageURLStr, insertedPodcast.imageURLStr)
            XCTAssertEqual(podcast.categories, insertedPodcast.categories)

            XCTAssertEqual(insertedPodcast.episodes.count, podcast.episodes.count)
            XCTAssertEqual(insertedPodcast.latestPublishedDate, latestEpisodePubDate)
            XCTAssertEqual(insertedPodcast.earliestPublishedDate, earliestEpisodePubDate)
        } catch {
            XCTFail("Failed \(#function): \(error)")
        }

    }

    let earliestEpisodePubDate: Date = {
        let dc = DateComponents(calendar: .current, timeZone: TimeZone(secondsFromGMT: 0), year: 2018, month: 3, day: 15, hour: 10, minute: 0, second: 0)
        return Calendar.current.date(from: dc)!
    }()
    let latestEpisodePubDate: Date = {
        let dc = DateComponents(calendar: .current, timeZone: TimeZone(secondsFromGMT: 0), year: 2018, month: 4, day: 20, hour: 5, minute: 29, second: 0)
        return Calendar.current.date(from: dc)!
    }()

    func testInsert() {
        do {
            let podcast = parsedPodcast()!
            let connection = try getConnection()

            try deleteExisting(podcast: podcast, connection: connection)

            // test what was inserted for the Podcast
            _ = try PodcastDBController.insert(db: connection, podcast: podcast).wait()
            let insertedPodcast = try PodcastDBController.getExistingPodcast(for: podcast, connection: connection).wait()
            XCTAssertEqual(insertedPodcast?.title, podcast.title)
            XCTAssertEqual(insertedPodcast?.url, podcast.url)
            XCTAssertEqual(insertedPodcast?.subtitle, podcast.subtitle)
            XCTAssertEqual(insertedPodcast?.allURLs, podcast.allURLs)
            XCTAssertEqual(insertedPodcast?.podcastDescription, podcast.podcastDescription)
            XCTAssertEqual(insertedPodcast?.summary, podcast.summary)
            XCTAssertEqual(insertedPodcast?.authorName, podcast.authorName)
            XCTAssertEqual(insertedPodcast?.copyright, podcast.copyright)
            XCTAssertEqual(insertedPodcast?.imageURLStr, podcast.imageURLStr)
            XCTAssertEqual(insertedPodcast?.categories, podcast.categories)
            XCTAssertEqual(insertedPodcast?.episodesCount, podcast.episodes.count)

            // test what was inserted for the Podcast's episodes
            let podcastId = insertedPodcast?.id
            XCTAssertNotNil(podcastId)
            let episodeRows = try PodcastDBController.getExistingEpisodes(for: podcastId!, connection: connection).wait()
            XCTAssertEqual(episodeRows.count, podcast.episodes.count)
            for row in episodeRows {
                let episode = Episode(row: row)
                XCTAssertNotNil(episode)
                if let episode = episode {
                    let matchingEpisode = podcast.episodes.first { $0.title == episode.title }
                    XCTAssertNotNil(matchingEpisode)
                    XCTAssertEqual(episode.title, matchingEpisode?.title)
                    XCTAssertEqual(episode.episodeDescription, matchingEpisode?.episodeDescription)
                    XCTAssertEqual(episode.guid, matchingEpisode?.guid)
                    XCTAssertEqual(episode.imageURL, matchingEpisode?.imageURL)
                    XCTAssertEqual(episode.duration, matchingEpisode?.duration)
                    XCTAssertEqual(episode.enclosureType, matchingEpisode?.enclosureType)
                    XCTAssertEqual(episode.enclosureLength, matchingEpisode?.enclosureLength)
                    XCTAssertEqual(episode.enclosureURL, matchingEpisode?.enclosureURL)
                    XCTAssertEqual(episode.podcastId, podcastId)
                    XCTAssertEqual(episode.link, matchingEpisode?.link)
                    XCTAssertEqual(episode.author, matchingEpisode?.author)
                    XCTAssertEqual(episode.keywords, matchingEpisode?.keywords)
                    XCTAssertEqual(episode.content, matchingEpisode?.content)
                }
            }
        } catch {
            XCTFail("Got an error: \(error)")
        }
    }

    func testUpsert() {
        do {
            let podcast1 = parsedPodcast()!
            let updatedTitle = "A new title"
            let podcast2 = Podcast(title: updatedTitle, url: podcast1.url)
            let connection = try getConnection()

            try deleteExisting(podcast: podcast1, connection: connection)

            let insertId1 = try PodcastDBController.insert(db: connection, podcast: podcast1).wait()
            let insertId2 = try PodcastDBController.insert(db: connection, podcast: podcast2).wait()
            let updatedPodcast = tryOrNil {
                try PodcastDBController.getExistingPodcast(for: podcast1, connection: connection).wait()
            }

            XCTAssertEqual(insertId1, insertId2)
            XCTAssertEqual(updatedPodcast?.title, updatedTitle)
        } catch {
            XCTFail("Got an error: \(error)")
        }
    }

    private func deleteExisting(podcast: Podcast, connection: PostgreSQLConnection) throws {
        let podcastId = tryOrNil {
            return try PodcastDBController.getExistingPodcast(for: podcast, connection: connection)
                .map(to: Int?.self) { $0?.id }
                .wait()
        }
        if let podcastId = podcastId {
            let episodeDeleteQueryStr = """
        DELETE FROM episodes WHERE "podcast_id" = $1
        """
            _ = try connection.query(episodeDeleteQueryStr, [podcastId]).wait()
        }
        let podcastDeleteQueryStr = """
            DELETE FROM podcasts WHERE "url" = $1
            """
        _ = try connection.query(podcastDeleteQueryStr, [podcast.url]).wait()
    }

    private var application: Application!

    private func getConnection() throws -> PostgreSQLConnection {
        var config = Config.default()
        var env = try Environment.detect()
        var services = Services.default()
        try App.configure(&config, &env, &services)

        application = try Application(config: config, environment: env, services: services)

        let connection = try application.connectionPool(to: .psql).requestConnection().wait()
        return connection
    }
}

