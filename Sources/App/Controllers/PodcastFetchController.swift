//
//  PodcastFetchController.swift
//  App
//
//  Created by Raheel Ahmad on 4/23/18.
//

import Foundation
import Vapor
import SWXMLHash
import PostgreSQL

typealias Row = [PostgreSQLColumn: PostgreSQLData]

final class PodcastFetchController {
    static func fetch(at feedURLStr: String, loop: EventLoop) throws -> Future<Podcast> {
        guard let url = URL(string: feedURLStr) else {
            throw Vapor.Abort(HTTPResponseStatus.badRequest, reason: "Bad URL provided")
        }
        let promise = loop.newPromise(Podcast.self)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let strResponse = String(data: data, encoding: .utf8) {
                do {
                    let podcast = try parse(podcastStr: strResponse, feedURLStr: feedURLStr)
                    promise.succeed(result: podcast)
                } catch {
                    promise.fail(error: error)
                }
            } else {
                promise.fail(error: APIFailure.feedFetch)
            }
        }.resume()
        return promise.futureResult
    }

    static func parse(podcastStr: String, feedURLStr: String) throws -> Podcast {
        let xml = SWXMLHash.config {
            $0.shouldProcessNamespaces = true
            }.parse(podcastStr)

        guard
            let podcastXML = xml.children.first?.children.first,
            let podcast = Podcast(xml: podcastXML, feedFetchURL: feedURLStr) else {
                throw ParsingError.xml
        }
        return podcast
    }
}
