import Foundation
import Vapor

import PostgreSQL
import SWXMLHash

let drop = try? Droplet()

drop?.get("/podcasts") { req in
    let episodesJSON = try PodcastDBController.allPodcasts().map { $0.dictWithoutEpisodes() }
    var resp = JSON()
    try resp.set("podcasts", episodesJSON)
    return resp
}

drop?.get("/feed") { req in
    let ids: [Int]? = req.query?["ids"]?.array?.flatMap { $0.int }
    guard let podcastIds: [Int] = ids else {
        throw Abort(.badRequest, reason: "No podcast ids provided")
    }
    let podcasts = try podcastIds
        .flatMap { try PodcastDBController.dbPodcast(forId: $0) }.map { $0.dictWithEpisodes() }
    var resp = JSON()
    try resp.set("feed", podcasts)
    return resp
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
