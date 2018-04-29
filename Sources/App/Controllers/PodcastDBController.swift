//
//  PodcastDBController.swift
//  App
//
//  Created by Raheel Ahmad on 4/26/18.
//

import Foundation
import Vapor
import PostgreSQL

final class PodcastDBController {
    private static let podcastSelectStr = "MIN(episodes.pub_date) as earliest_published_date, MAX(episodes.pub_date) as latest_published_date, SUM(episodes.duration)/COUNT(episodes.duration) AS average_duration, COUNT(episodes) AS episodes_count, podcasts.*"
    private static let podcastFromStr = "podcasts INNER JOIN episodes ON podcasts.id = episodes.podcast_id"
    private static let podcastGroupByStr = "GROUP BY podcasts.id"

    static func podcast(forId id: Int, connection: PostgreSQLConnection) throws -> Future<Podcast> {
        return try getExistingPodcast(query: ("id", id), connection: connection)
            .map(to: Podcast.self) {
                if let podcast = $0 { return podcast }
                else { throw DBError.idNotFound }
        }
    }

    static func getExistingPodcast(for podcast: Podcast, connection: PostgreSQLConnection) throws -> Future<Podcast?>  {
        return try getExistingPodcast(url: podcast.url, connection: connection)
    }

    static func getExistingPodcast(url: String, connection: PostgreSQLConnection) throws -> Future<Podcast?>  {
        return try getExistingPodcast(query: ("url", url), connection: connection)
    }

    static func getExistingPodcast(query: (key: String, value: PostgreSQLDataConvertible), connection: PostgreSQLConnection) throws -> Future<Podcast?>  {
        return getExistingPodcastRow(query: query, connection: connection)
            .flatMap(to: Podcast?.self, { row in
                guard let podcastRow = row, let podcastId = Podcast(row: podcastRow)?.id else {
                    return .map(on: connection) { nil }
                }
                return getExistingEpisodes(for: podcastId, connection: connection)
                    .map(to: Podcast?.self) { episodeRows in
                        return Podcast(row: podcastRow, episodeRows: episodeRows)
                }
            })
    }

    static func getExistingPodcastRow(query: (key: String, value: PostgreSQLDataConvertible), connection: PostgreSQLConnection) -> Future<Row?>  {
        let selectQueryStr = """
        SELECT \(podcastSelectStr) FROM \(podcastFromStr) WHERE "\(query.key)" = $1 \(podcastGroupByStr)
        """
        return connection
            .query(selectQueryStr, [query.value])
            .map(to: Row?.self) { $0.first }
    }

    static func getExistingEpisodes(for podcastId: Int, connection: PostgreSQLConnection) -> Future<[Row]>  {
        let selectQueryStr = """
            SELECT * FROM episodes WHERE "podcast_id" = $1
            """
        return connection.query(selectQueryStr, [podcastId])
    }


    static func insert(db: PostgreSQLConnection, podcast: Podcast) throws -> Future<Int?> {
        let podcastDict = podcast.dbDict
        let columnsStr = Array(podcastDict.keys)
            .map { "\"\($0)\"" }
            .joined(separator: ", ")
        let valuesStr = Array(podcastDict.values) as! [PostgreSQLDataConvertible]
        let valuePlaceholderStr = (0..<valuesStr.count)
            .map { "$\($0+1)"}
            .joined(separator: ", ")
        let queryStr = """
        INSERT INTO podcasts (\(columnsStr)) VALUES (\(valuePlaceholderStr))
        ON CONFLICT (url)
        DO UPDATE set (\(columnsStr)) = (\(valuePlaceholderStr))
        RETURNING id
        """
        let podcastInsertFut = db.query(queryStr, valuesStr)
            .map(to: Int?.self) { rows in
                return try rows.first?.firstValue(forColumn: "id")?.decode(Int.self)
        }
        for episode in podcast.episodes {
            _ = podcastInsertFut.flatMap(to: [Row].self) { podcastId in
                return try insertEpisodes(db: db, episode: episode, podcastId: podcastId)
            }
        }
        return podcastInsertFut
    }

    static func insertEpisodes(db: PostgreSQLConnection, episode: Episode, podcastId: Int?) throws -> Future<[Row]> {
        let episodeDict = episode.dbDict(podcastId: podcastId)
        let columnsStr = Array(episodeDict.keys)
            .map { "\"\($0)\"" }
            .joined(separator: ", ")
        let valuesStr = Array(episodeDict.values) as! [PostgreSQLDataConvertible]
        let valuePlaceholderStr = (0..<valuesStr.count)
            .map { "$\($0+1)"}
            .joined(separator: ", ")
        let queryStr = """
        INSERT INTO episodes (\(columnsStr)) VALUES (\(valuePlaceholderStr))
        ON CONFLICT (guid)
        DO UPDATE set (\(columnsStr)) = (\(valuePlaceholderStr))
        """
        return db.query(queryStr, valuesStr)
    }

}
