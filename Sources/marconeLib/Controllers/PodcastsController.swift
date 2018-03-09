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

    public static func allPodcastsJSON() throws -> [[String: Any]] {
        return try PodcastDBController.allPodcasts().map { $0.dictWithoutEpisodes() }
    }

    public static func podcastsJSON(forIds podcastIds: [Int]) throws -> [[String: Any]] {
        return try podcastIds
            .flatMap { try PodcastDBController.dbPodcast(forId: $0) }.map { $0.dictWithEpisodes() }
    }

    public static func podcastJSON(forURL url: String) throws -> [String: Any]? {
        return try PodcastDBController.dbPodcast(forURL: url)?.dictWithEpisodes()
    }

    public static func podcastJSON(fromURL podcastURLString: String) throws -> [String: Any] {
        let insertedPodcast = try _addOrUpdate(fromURL: podcastURLString)
        return insertedPodcast.dictWithEpisodes()
    }

    @discardableResult
    static func _addOrUpdate(fromURL podcastURLString: String) throws -> Podcast {
        // Fetch feed
        let podcast = try PodcastFetchController.podcast(fromURL: podcastURLString)
        // Insert
        let insertedPodcast = try PodcastDBController.addOrUpdate(podcast: podcast)
        return insertedPodcast
    }

    public static func addOrUpdate(fromURL podcastURLString: String) throws {
        try _addOrUpdate(fromURL: podcastURLString)
    }
}
