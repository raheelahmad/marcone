import Foundation
import Vapor
import marconeLib

var config = try Config()
try config.set("server.hostname", "0.0.0.0")
try config.set("server.port", "9000")
try config.set("server.securityLayer", "none")
config.addConfigurable(command: FeedRefreshCommand.init, name: "refresh")
let drop = try? Droplet(config)

drop?.get("/podcasts") { req in
    let episodesJSON = try PodcastsController.allPodcastsJSON()
    var resp = JSON()
    try resp.set("podcasts", episodesJSON)
    return resp
}

drop?.get("/feed") { req in
    let ids: [Int]? = req.query?["ids"]?.array?.flatMap { $0.int }
    guard let podcastIds: [Int] = ids else {
        throw Abort(.badRequest, reason: "No podcast ids provided")
    }
    let podcasts = try PodcastsController.podcastsJSON(forIds: podcastIds)
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
        if let podcastJSON = try PodcastsController.podcastJSON(forURL: podcastURL) {
            print("Found existing podcast for \(podcastURL)")
            var resp = JSON()
            try resp.set("podcast", podcastJSON)
            return resp
        }

        // Reply
        let podcastJSON = try PodcastsController.podcastJSON(fromURL: podcastURL)
        var resp = JSON()
        try resp.set("podcast", podcastJSON)
        print("Fetched and inserted podcast for \(podcastURL)")
        return resp
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
