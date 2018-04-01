import Foundation
import Vapor
import marconeLib

var config = try Config()
try config.set("server.hostname", "0.0.0.0")
try config.set("server.port", "9000")
try config.set("server.securityLayer", "none")
config.addConfigurable(command: FeedRefreshCommand.init, name: "refresh-feed")
config.addConfigurable(command: DirectoryRefreshCommand.init, name: "refresh-directory")
let drop = try? Droplet(config)

drop?.get("/directory") { req in
    guard let workDir = drop?.config.workDir else {
        return "Failed"
    }
    let json = try DirectoryFetchController.fetch(workDir: workDir)
    var resp = JSON()
    try resp.set("result", json)
    return resp
}

drop?.get("/podcasts") { req in
    if let podcastJSON = try req.query?["url"]
        .flatMap({ $0.string })
        .flatMap({ try PodcastsController.podcastJSON(onlyFromURL: $0) })
    {
        var resp = JSON()
        try resp.set("podcast", podcastJSON)
        return resp
    } else {
        throw Abort(.badRequest, metadata: "No URL provided")
    }
}

drop?.get("/feed") { req in
    var ids: [Int]? = req.query?["ids"]?.array?.compactMap { $0.int }
    if ids == nil, let singleId = req.query?["ids"]?.int {
        ids = [singleId]
    }

    var resp = JSON()
    if let podcastIds: [Int] = ids {
        let podcasts = try PodcastsController.podcastsJSON(forIds: podcastIds)
        try resp.set("feed", podcasts)
    } else {
        try resp.set("feed", [])
    }
    return resp
}

drop?.post("/feed") { req in
    do {
        guard let podcastURL = req.json?["podcast_url"]?.string else {
            throw Abort(.badRequest, reason: "Bad Podcast URL")
        }

        // Reply with an id if podcast is in DB
        // We don't update (episodes etc.) in this case, since a background job
        // must be doing that.
        if let podcastId = try PodcastsController.dbPodcastId(fromURL: podcastURL) {
            print("Found existing podcast for \(podcastURL)")
            var resp = JSON()
            try resp.set("podcast_id", podcastId)
            return resp
        }

        // Reply
        let podcastId = try PodcastsController.podcastJSON(fromURL: podcastURL)
        var resp = JSON()
        try resp.set("podcast_id", podcastId)
        print("Fetched and inserted podcast for \(podcastURL)")
        return resp
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
