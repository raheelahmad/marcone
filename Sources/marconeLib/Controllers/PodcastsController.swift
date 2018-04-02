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

    public static func podcastJSON(fromURL podcastURLString: String) throws -> [String: Any]? {
        if let podcast = try PodcastDBController.dbPodcast(forURL: podcastURLString) {
            return podcast.jsonWithEpisodes()
        } else {
            return try _addOrUpdate(fromURL: podcastURLString)
        }
    }

    @discardableResult
    static func _addOrUpdate(fromURL podcastURLString: String) throws -> [String: Any]? {
        // Fetch feed
        let podcast = try PodcastFetchController.podcast(fromURL: podcastURLString)
        // Insert
        return try PodcastDBController.addOrUpdate(podcast: podcast)
    }

    public static func addOrUpdate(fromURL podcastURLString: String) throws {
        try _addOrUpdate(fromURL: podcastURLString)
    }
}
