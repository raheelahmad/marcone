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
        guard let podcastURL = req.data["podcast_url"]?.string else {
            throw Abort(.badRequest, reason: "Bad Podcast URL")
        }

        // Reply with an id if podcast is in DB
        // We don't update (episodes etc.) in this case, since a background job
        // must be doing that.
        if let podcast = try PodcastDBController.dbPodcast(forURL: podcastURL) {
            print("Found existing id \(podcast.id ?? "--------") for \(podcastURL)")
            var resp = JSON()
            try resp.set("podcast", podcast.dictWithEpisodes())
            return resp
        }

        // Fetch feed
        let cast = try PodcastFetchController.podcast(fromURL: podcastURL)
        // Insert
        let insertedPodcast = try PodcastDBController.addOrUpdate(podcast: cast)
        // Reply
        var resp = JSON()
        try resp.set("podcast", insertedPodcast.dictWithEpisodes())
        print("Fetched and inserted id \(insertedPodcast.id ?? "--------") for \(podcastURL)")
        return resp
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
