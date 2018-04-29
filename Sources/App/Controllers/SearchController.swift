//
//  SearchController.swift
//  App
//
//  Created by Raheel Ahmad on 4/28/18.
//

import Foundation
import Vapor

extension Dictionary where Key == String {
    func nestedJSON(key: String)  -> JSON? {
        return self[key] as? JSON
    }
    func nestedArray(key: String)  -> [JSON] {
        return self[key] as? [JSON] ?? []
    }
}

struct SearchResponse: Content {
    let podcasts: [TunesPodcast]
}

public final class SearchController {
    private static var results: [String: SearchResponse] = [:]
    static func search(request: Request) throws -> Future<SearchResponse> {
        let query: String
        do {
            query = try request.query.get(String.self, at: "term")
        } catch {
            throw Abort(.badRequest, reason: "No query provided")
        }
        if let cachedResult = results[query] {
            return .map(on: request) { cachedResult }
        }

        let client = try request.make(Client.self)

        guard
            let baseURL = URL(string: "https://itunes.apple.com/search"),
            var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            else {
                throw Abort(.internalServerError, reason: "Could not construct search URL")
        }
        comps.queryItems = [URLQueryItem(name: "term", value: query), URLQueryItem(name: "entity", value: "podcast")]
        guard let url = comps.url else {
            throw Abort(.internalServerError, reason: "Could not construct search URL")
        }
        return client.get(url)
            .flatMap(to: SearchResponse.self) { response in
                try tunesPodcasts(for: url.absoluteString, container: request)
                    .map(to: SearchResponse.self) { SearchResponse(podcasts: $0) }
            }.do { response in
                results[query] = response
        }
    }

    /// Fetches the top 25 podcasts for the given category
    ///
    /// - Parameters:
    ///   - category: The category (genre)
    ///   - container: Container
    /// - Returns: the category and its parsed Podcasts
    /// - Note: TODO: This call can error out, so eventually we need to build an algorithm that refreshes
    ///               conditionally the failed podcasts fetch.
    static func tunesPodcasts(for category: TunesCategory, container: Container) throws -> Future<(TunesCategory, [TunesPodcast])> {
        let id = category.id
        let searchURL = "https://itunes.apple.com/search?term=podcast&genreId=\(id)&limit=25"
        return try tunesPodcasts(for: searchURL, container: container)
            .map(to: (TunesCategory, [TunesPodcast]).self) { (category, $0) }
            .catchMap { error in
                print("Error fetching podcasts for \(category.name)")
                return (category, [])
            }
    }

    static func tunesPodcasts(for url: String, container: Container) throws -> Future<[TunesPodcast]> {
        return try container.make(Client.self)
            .get(url)
            .map(to: [TunesPodcast].self) { response in
                guard let data = response.http.body.data,
                    let jsonRaw = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    else {
                        print("No podcasts found for \(url)")
                        throw Abort(.internalServerError, reason: "Error parsing podcasts")
                }
                let podcasts: [TunesPodcast] = jsonRaw.nestedArray(key: "results").compactMap {
                    if let title = $0["trackName"] as? String, let feedURL = $0["feedUrl"] as? String {
                        let imageURL = ($0["artworkUrl600"] ?? $0["artworkUrl100"] ?? $0["artworkUrl60"] ?? $0["artworkUrl30"]) as? String
                        return TunesPodcast(title: title, feedURL: feedURL, imageURL: imageURL)
                    } else {
                        return nil
                    }
                }
                return podcasts
        }
    }
}
