//
//  TunesFetchController.swift
//  marconeLib
//
//  Created by Raheel Ahmad on 3/27/18.
//

import Foundation
import PostgreSQL

extension Dictionary where Key == String {
    func nestedJSON(key: String)  -> JSON? {
        return self[key] as? JSON
    }
    func nestedArray(key: String)  -> [JSON] {
        return self[key] as? [JSON] ?? []
    }
}

enum TunesFetchError: Error {
    case badGenreURL
}

private let genresURLString = "http://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres"

/*
 1. Fetches all categories (aka genres) on iTunes
 2. For each category fetches the podcasts
 3. Stores
 */
public final class TunesFetchController {
    typealias CategoryID = String
    typealias PodcastURL = String
    private static var podcasts: [PodcastURL: TunesPodcast] = [:]
    private static var categoryPodcasts: [CategoryID: [PodcastURL]] = [:]
    private static var categories: [TunesCategory] = []

    struct TunesPodcast {
        let title: String
        let feedURL: PodcastURL
        let imageURL: String?
    }

    struct TunesCategory {
        let name: String
        let id: CategoryID
        let sub: [TunesCategory]
    }

    public static func fetch() throws {
        let categories = try fetchCategories()
        let allCategories: [TunesCategory] = categories.reduce([]) { $0 + [$1] + $1.sub }
        var allPodcasts: [PodcastURL: TunesPodcast] = [:]
        for category in allCategories {
            let podcasts = try fetchPodcasts(for: category)
            let podcastsByURL: [PodcastURL: TunesPodcast] = podcasts.reduce([PodcastURL:TunesPodcast]()) {
                (dict: [PodcastURL: TunesPodcast], podcast: TunesPodcast) in
                var mutableDict = dict
                mutableDict[podcast.feedURL] = podcast
                return mutableDict
            }
            self.categoryPodcasts[category.id] = Array(podcastsByURL.keys)
            allPodcasts.merge(podcastsByURL, uniquingKeysWith: { (a, b) in a })
        }
        self.categories = allCategories
        self.podcasts = allPodcasts
    }

    private static func fetchPodcasts(for category: TunesCategory) throws -> [TunesPodcast] {
        let id = category.id
        let categoryURL = URL(string: "https://itunes.apple.com/search?term=podcast&genreId=\(id)&limit=5")!
        let categoriesData = try Data(contentsOf: categoryURL)
        let json = try JSONSerialization.jsonObject(with: categoriesData, options: []) as? [String: Any]
        let podcasts: [TunesPodcast] = json!.nestedArray(key: "results").flatMap {
            if let title = $0["trackName"] as? String, let feedURL = $0["feedUrl"] as? String {
                let imageURL = ($0["artworkUrl600"] ?? $0["artworkUrl100"] ?? $0["artworkUrl60"] ?? $0["artworkUrl30"]) as? String
                return TunesPodcast(title: title, feedURL: feedURL, imageURL: imageURL)
            } else {
                return nil
            }
        }
        return podcasts
    }

    private static func fetchCategories() throws -> [TunesCategory] {
        let contentData = try Data(contentsOf: URL(string: genresURLString)!)

        let json = try JSONSerialization.jsonObject(with: contentData, options: []) as! [String: Any]
        let podcastGenres = json["26"] as! [String: Any]
        let genres = podcastGenres["subgenres"] as! [String: Any]
        return categoriesFrom(json: genres)
    }

    private static func categoriesFrom(json categoriesJSON: [String: Any]) -> [TunesCategory] {
        let result: [TunesCategory] = categoriesJSON.flatMap {
            if let name = ($0.value as? [String: Any])?["name"] as? String {
                if let subJSON = ($0.value as? [String: Any])?["subgenres"] as? [String: Any] {
                    let sub = categoriesFrom(json: subJSON)
                    return TunesCategory(name: name, id: $0.key, sub: sub)
                } else {
                    return TunesCategory(name: name, id: $0.key, sub: [])
                }
            } else {
                return nil
            }
        }
        return result
    }
}
