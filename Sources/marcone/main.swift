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

        if let id = try PodcastDBController.id(forURL: podcastURL) {
            print("Found existing id \(id) for \(podcastURL)")
            var resp = JSON()
            try resp.set("podcast_id", id)
            return resp
        }

        let cast = try PodcastFetchController.podcast(fromURL: podcastURL)

        let id = try PodcastDBController.addOrUpdate(podcast: cast)
        var resp = JSON()
        try resp.set("podcast_id", id)
        print("Fetched and inserted id \(id) for \(podcastURL)")
        return resp
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
