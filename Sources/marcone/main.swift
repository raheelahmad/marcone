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
    try resp.set("podcasts", json.podcasts)
    try resp.set("categories", json.categories)
    return resp
}

drop?.get("/search") { req in
    guard let query = req.query?["term"]?.string else {
        throw Abort(.badRequest, metadata: "No Term provided")
    }
    let json = try SearchController.search(query: query)
    var resp = JSON()
    try resp.set("result", json)
    return resp
}

drop?.get("/podcasts") { req in
    if let podcastJSON = try req.query?["url"]
        .flatMap({ $0.string })
        .flatMap({ try PodcastsController.podcastJSON(fromURL: $0) })
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

_ = try? drop?.run()
