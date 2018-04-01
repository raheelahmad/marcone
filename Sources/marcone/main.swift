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
    let episodesJSON = try PodcastsController.allPodcastsJSON()
    var resp = JSON()
    try resp.set("podcasts", episodesJSON)
    return resp
}

drop?.get("/feed") { req in
    var ids: [Int]? = req.query?["ids"]?.array?.flatMap { $0.int }
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

drop?.get("/podcasts/", Int.parameter) { req in
    let id = try req.parameters.next(Int.self)
    let podcast = try PodcastsController.podcastJSON(forId: id)
    var resp = JSON()
    try resp.set("podcast", podcast)
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
