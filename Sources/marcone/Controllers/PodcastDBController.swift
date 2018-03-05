//
//  PodcastController.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation

final class PodcastDBController {
    static func id(forURL url: URL) throws -> Int? {
        let database = try db()
        let res = try database.execute("SELECT id FROM podcasts WHERE url = $1", [url.absoluteString])[0]
        let existingPodcastId: Int? = try res?.get("id")
        return existingPodcastId
    }

    static func addOrUpdate(podcast: Podcast) throws -> Int {
        do {
            let database = try db()
            let podcastId: Int?
            let res = try database.execute("SELECT id FROM podcasts WHERE url = $1", [podcast.url])[0]
            let existingPodcastId: Int? = try res?.get("id")
            if let existingId = existingPodcastId {
                podcastId = existingId
            } else {
                let podcastValues = podcast.dictWithoutEpisodes(podcastId: nil)
                let podcastInsert = InsertRequest(db: database, table: "podcasts", valueDict: podcastValues, returning: ["id"])
                podcastId = try insertWith(request: podcastInsert)["id"]?.int
            }
            guard let id = podcastId else {
                throw DatabaseError.podcastInsertion
            }
            for category in podcast.categories {
                let categoryInsert = InsertRequest(db: database, table: "categories", valueDict: ["name": category], onConflict: .doNothing)
                try insertWith(request: categoryInsert)
                let joinInsert = InsertRequest(db: database, table: "podcast_categories", valueDict: ["podcast_id": id, "category_name": category], onConflict: .doNothing)
                try insertWith(request: joinInsert)
            }
            
            for episode in podcast.episodes {
                let episodeValues = episode.jsonDict(podcastId: id)
                let onConflictUpdateKeys: [String] = Array(episodeValues.keys.filter { $0 != "guid" })
                let onConflict = InsertRequest.OnConflict.update(conflicting: ["guid"], updateKeys: onConflictUpdateKeys)
                let episodeInsert = InsertRequest(db: database, table: "episodes", valueDict: episodeValues, onConflict: onConflict)
                try insertWith(request: episodeInsert)
            }

            return id

        } catch let error {
            throw error
        }
    }
}
