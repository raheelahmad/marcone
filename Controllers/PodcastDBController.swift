//
//  PodcastController.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation

final class PodcastDBController {
    private static var df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
        return df
    }()

    static func id(forURL url: URL) throws -> Int? {
        let database = try db()
        let res = try database.execute("SELECT id FROM podcasts WHERE url = $1", [url.absoluteString])[0]
        let existingPodcastId: Int? = try res?.get("id")
        return existingPodcastId
    }

    static func addOrUpdate(podcast: Podcast) throws -> Int {
        do {
            let podcastValues = [
                "url": podcast.url,
                "title": podcast.title,
                "subtitle": podcast.subtitle,
                "description": podcast.podcastDescription,
                "summary": podcast.summary,
                "author_name": podcast.authorName,
                "copyright": podcast.copyright,
                "image_url": podcast.imageURLStr,
                ]
            let database = try db()
            let podcastId: Int?
            let res = try database.execute("SELECT id FROM podcasts WHERE url = $1", [podcast.url])[0]
            let existingPodcastId: Int? = try res?.get("id")
            if let existingId = existingPodcastId {
                podcastId = existingId
            } else {
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
                let pubDateInterval = episode.publicationDate.flatMap(df.date)
                let episodeValues: [String: Any?] = [
                    "title": episode.title,
                    "description": episode.episodeDescription,
                    "guid": episode.guid,
                    "image_url": episode.imageURL,
                    "pub_date": pubDateInterval,
                    "duration": episode.duration,
                    "enclosure_type": episode.enclosureType,
                    "enclosure_length": episode.enclosureLength,
                    "enclosure_url": episode.enclosureURL,
                    "podcast_id": id,
                    ]
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
