//
//  PodcastsController.swift
//  marconeLib
//
//  Created by Raheel Ahmad on 3/9/18.
//

import Foundation

public final class PodcastsController {
    public static func allURLs() throws -> [String] {
        return try PodcastDBController.allURLs()
    }

    public static func podcastJSON(onlyFromURL url: String) throws -> [String: Any]? {
        return try PodcastFetchController.podcast(fromURL: url).jsonWithEpisodes()
    }

    public static func podcastsJSON(forIds podcastIds: [Int]) throws -> [[String: Any]] {
        return try podcastIds.compactMap { try PodcastDBController.dbPodcast(forId: $0) }.map { $0.jsonWithEpisodes() }
    }
    public static func podcastJSON(forId id: Int) throws -> [String: Any]? {
        return try PodcastDBController.dbPodcast(forId: id)?.jsonWithEpisodes()
    }
    public static func dbPodcastJSON(fromURL url: String) throws -> [String: Any]? {
        return try PodcastDBController.dbPodcast(forURL: url)?.jsonWithEpisodes()
    }
    public static func dbPodcastId(fromURL url: String) throws -> Int? {
        return try PodcastDBController.dbPodcastId(forURL: url)
    }

    public static func podcastJSON(fromURL podcastURLString: String) throws -> Int {
        let podcastId = try _addOrUpdate(fromURL: podcastURLString)
        return podcastId
    }

    @discardableResult
    static func _addOrUpdate(fromURL podcastURLString: String) throws -> Int {
        // Fetch feed
        let podcast = try PodcastFetchController.podcast(fromURL: podcastURLString)
        // Insert
        let insertedPodcastId = try PodcastDBController.addOrUpdate(podcast: podcast)
        return insertedPodcastId
    }

    public static func addOrUpdate(fromURL podcastURLString: String) throws {
        try _addOrUpdate(fromURL: podcastURLString)
    }
}
