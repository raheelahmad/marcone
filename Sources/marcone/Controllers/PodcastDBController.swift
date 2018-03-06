//
//  PodcastController.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation

final class PodcastDBController {
    static func dbPodcast(forURL url: String) throws -> Podcast? {
        let database = try db()
        let node = try database.execute("SELECT * FROM podcasts WHERE url = $1 OR $1 = ANY (all_urls)", [url])[0]
        guard let podcastNode = node, let podcastId: Int = try podcastNode.get("id") else {
            return nil
        }
        let episodeNodes = try database.execute("SELECT * FROM episodes WHERE podcast_id = $1", [podcastId]).array ?? []
        let categoryNodes = try database.execute("SELECT category_name FROM podcast_categories WHERE podcast_id = $1", [podcastId]).array ?? []
        let podcast = Podcast(node: podcastNode, categoryNodes: categoryNodes, episodeNodes: episodeNodes)
        return podcast
    }

    static func addOrUpdate(podcast: Podcast) throws -> Podcast {
        do {
            let database = try db()
            let podcastValues = podcast.dictWithoutEpisodes()
            let podcastInsert = InsertRequest(db: database, table: "podcasts", valueDict: podcastValues, returning: ["id"])
            guard let podcastId = try insertWith(request: podcastInsert)["id"]?.int else {
                throw DatabaseError.podcastInsertion
            }
            for category in podcast.categories {
                let joinInsert = InsertRequest(db: database, table: "podcast_categories", valueDict: ["podcast_id": podcastId, "category_name": category], onConflict: .doNothing)
                try insertWith(request: joinInsert)
            }
            
            for episode in podcast.episodes {
                let episodeValues = episode.jsonDict(podcastId: podcastId)
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
