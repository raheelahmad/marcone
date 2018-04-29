import Vapor
import Routing
import PostgreSQL

public func routes(_ router: Router) throws {
    router.get("/") { request in
        return "Hello!"
    }

    router.get("/podcasts") { request -> Future<PodcastResponse> in
        return try PodcastController.fetchPodcast(request: request)
    }

    router.get("/feed") { request -> Future<FeedResponse> in
        return try PodcastController.dbPodcasts(request: request)
    }

    router.get("/directory") { request -> Future<DirectoryResponse> in
        return try DirectoryFetchController.fetch(req: request)
    }

    router.get("/search") { request -> Future<SearchResponse> in
        return try SearchController.search(request: request)
    }
}
