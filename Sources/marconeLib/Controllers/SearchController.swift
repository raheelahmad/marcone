//
//  SearchController.swift
//  BCrypt
//
//  Created by Raheel Ahmad on 4/4/18.
//

import Foundation
import Vapor

typealias PodcastURL = String

struct TunesPodcast: Equatable {
    static func ==(lhs: TunesPodcast, rhs: TunesPodcast) -> Bool {
        return lhs.feedURL == rhs.feedURL
    }

    let title: String
    let feedURL: PodcastURL
    let imageURL: String?

    var json: JSON {
        var dict = ["title": title, "feed_url": feedURL]
        dict["image_url"] = imageURL
        return dict
    }
}

public final class SearchController {
    private static var results: [String: [[String: Any]]] = [:]
    public static func search(query: String) throws -> [[String: Any]] {
        if let cachedResult = results[query] {
            return cachedResult
        }
        guard
            let baseURL = URL(string: "https://itunes.apple.com/search"),
            var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw Abort(.internalServerError, metadata: "Could not construct search URL")
        }
        comps.queryItems = [URLQueryItem(name: "term", value: query), URLQueryItem(name: "entity", value: "podcast")]
        guard let url = comps.url else {
            throw Abort(.internalServerError, metadata: "Could not construct search URL")
        }

        let podcasts = try tunesPodcasts(from: url)
        let podcastsJSON = podcasts.map { $0.json}
        results[query] = podcastsJSON
        return podcastsJSON
    }

    static func tunesPodcasts(from url: URL) throws -> [TunesPodcast] {
        let podcastsData = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: podcastsData, options: []) as? [String: Any]
        let podcasts: [TunesPodcast] = json!.nestedArray(key: "results").compactMap {
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
