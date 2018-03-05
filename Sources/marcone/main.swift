import Foundation
import Vapor

import PostgreSQL
import SWXMLHash

let drop = try? Droplet()

drop?.get("/") { req in
    return ""
}

drop?.post("/add") { req in
    do {
        guard let podcastURLStr = req.data["podcast_url"]?.string, let podcastURL = URL(string: podcastURLStr) else {
            throw Abort(.badRequest, reason: "Bad Podcast URL")
        }

        // Reply with an id if podcast is in DB
        if let id = try PodcastDBController.id(forURL: podcastURL) {
            print("Found existing id \(id) for \(podcastURL)")
            var resp = JSON()
            try resp.set("podcast_id", id)
            return resp
        }

        // Fetch feed
        let cast = try PodcastFetchController.podcast(fromURL: podcastURL)
        // Insert
        let id = try PodcastDBController.addOrUpdate(podcast: cast)
        // Reply
        var resp = JSON()
        try resp.set("podcast_id", id)
        print("Fetched and inserted id \(id) for \(podcastURL)")
        return resp
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
