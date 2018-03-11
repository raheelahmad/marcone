//
//  PodcastController.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation

final class PodcastDBController {
    static func allPodcasts() throws -> [Podcast] {
        let database = try db()
        let nodes = try database.execute("SELECT * FROM podcasts" ).array ?? []
        let podcasts = nodes.flatMap { Podcast(node: $0) }
        return podcasts
    }

    static func allURLs() throws -> [String] {
        let database = try db()
        let nodes = try database.execute("SELECT url FROM podcasts").array ?? []
        return nodes.flatMap { $0["url"]?.string }
    }

    static func dbPodcast(forId podcastId: Int) throws -> Podcast? {
        let database = try db()
        let node = try database.execute("SELECT * FROM podcasts WHERE id = $1", [podcastId])[0]
        guard let podcastNode = node, let podcastId: Int = try podcastNode.get("id") else {
            return nil
        }
        let episodeNodes = try database.execute("SELECT * FROM episodes WHERE podcast_id = $1", [podcastId]).array ?? []
        let podcast = Podcast(node: podcastNode, episodeNodes: episodeNodes)
        return podcast
    }

    static func dbPodcast(forURL url: String) throws -> Podcast? {
        let database = try db()
        let node = try database.execute("SELECT * FROM podcasts WHERE url = $1 OR $1 = ANY (all_urls)", [url])[0]
        guard let podcastNode = node, let podcastId: Int = try podcastNode.get("id") else {
            return nil
        }
        let episodeNodes = try database.execute("SELECT * FROM episodes WHERE podcast_id = $1", [podcastId]).array ?? []
        let podcast = Podcast(node: podcastNode, episodeNodes: episodeNodes)
        return podcast
    }

    @discardableResult
    static func addOrUpdate(podcast: Podcast) throws -> Podcast {
        do {
            let database = try db()
            let podcastValues = podcast.dbDict
            let onConfliceUpdateKeys = Array(podcastValues.keys.filter { $0 != "url" })
            let onConflict = InsertRequest.OnConflict.update(conflicting: ["url"], updateKeys: onConfliceUpdateKeys)
            let podcastInsert = InsertRequest(db: database, table: "podcasts", valueDict: podcastValues, onConflict: onConflict, returning: ["id"])
            guard let podcastId = try insertWith(request: podcastInsert)["id"]?.int else {
                throw DatabaseError.podcastInsertion
            }

            for episode in podcast.episodes {
                let episodeValues = episode.dbDict(podcastId: podcastId)
                let onConflictUpdateKeys: [String] = Array(episodeValues.keys.filter { $0 != "guid" })
                let onConflict = InsertRequest.OnConflict.update(conflicting: ["guid"], updateKeys: onConflictUpdateKeys)
                let episodeInsert = InsertRequest(db: database, table: "episodes", valueDict: episodeValues, onConflict: onConflict)
                try insertWith(request: episodeInsert)
            }

            guard let podcast = try dbPodcast(forURL: podcast.url) else {
                throw DatabaseError.podcastInsertion
            }
            return podcast
        } catch let error {
            throw error
        }
    }
}
