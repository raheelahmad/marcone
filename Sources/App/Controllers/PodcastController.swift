//
//  PodcastController.swift
//  App
//
//  Created by Raheel Ahmad on 4/26/18.
//

import Foundation
import Vapor

struct FeedResponse: Content {
    let podcasts: [Podcast]
}

final class PodcastController {
    static func dbPodcasts(request: Request) throws -> Future<FeedResponse> {
        let ids: [Int]
        do {
            let idsStr = try request.query.get(String.self, at: "ids")
            ids = idsStr.components(separatedBy: ",").compactMap { Int($0) }
        } catch {
            throw Vapor.Abort(HTTPResponseStatus.badRequest, reason: "No podcast ids provided")
        }
        guard ids.count > 0 else {
            throw Vapor.Abort(HTTPResponseStatus.badRequest, reason: "No podcast ids provided")
        }

        let connectionFut = request.newConnection(to: .psql)
        return connectionFut.flatMap(to: FeedResponse.self) { connection in
            return try ids
                .map { try PodcastDBController.podcast(forId: $0, connection: connection) }
                .flatten(on: request)
                .map { FeedResponse(podcasts: $0) }
                .always {
                    connection.close()
                }
            }
    }

    static func fetchPodcast(request: Request) throws -> Future<PodcastResponse> {
        let feedURLStr: String
        do {
            feedURLStr = try request.query.get(String.self, at: ["url"])
        } catch {
            throw Vapor.Abort(HTTPResponseStatus.badRequest, reason: "No URL provided")
        }
        let connectionFut = request.newConnection(to: .psql)

        return connectionFut.flatMap(to: Podcast.self) { connection in
            return try PodcastDBController.getExistingPodcast(url: feedURLStr, connection: connection)
                .flatMap(to: Podcast.self) { dbPodcast in
                    if let podcast = dbPodcast {
                        return .map(on: request) { podcast }
                    }

                    let fetchFromRemoteFut: Future<Podcast> = try PodcastFetchController.fetch(at: feedURLStr, loop: request.eventLoop)
                    let inserted: Future<Podcast> = connectionFut.and(fetchFromRemoteFut).flatMap(to: Podcast.self) { comboFut in
                        return try PodcastDBController.insert(db: connection, podcast: comboFut.1)
                            .flatMap(to: Podcast.self) { id in
                                return try PodcastDBController.podcast(forId: id!, connection: comboFut.0)
                        }
                    }
                    return inserted
                }
                .always {
                    connection.close()
                }
            }
            .map { PodcastResponse.podcast($0) }
    }

}
