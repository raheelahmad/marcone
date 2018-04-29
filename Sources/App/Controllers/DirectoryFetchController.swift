//
//  DirectoryFetchController.swift
//  App
//
//  Created by Raheel Ahmad on 4/28/18.
//

import Foundation
import Vapor

typealias PodcastURL = String
typealias CategoryID = String

struct TunesPodcast: Content, Equatable, Hashable {
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

    var hashValue: Int {
        return feedURL.hashValue
    }
}

struct TunesCategory: Content, Equatable {
    enum CodingKeys: String, CodingKey {
        case categories = "subgenres"
        case name
        case id
    }

    let name: String
    let id: CategoryID
    let categories: [TunesCategory]

    var json: JSON { return ["name": name, "id": id, "sub_categories": categories.map { $0.json } ]}

    static func ==(lhs: TunesCategory, rhs: TunesCategory) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DirectoryResponse: Content {
    let categories: [TunesCategory]
    let podcasts: [TunesPodcast]
    let categoryPodcasts: [CategoryID: [Int]]
}

public final class DirectoryFetchController {
    private static var podcastsByURL: [PodcastURL: TunesPodcast] = [:]
    private static var categoryPodcasts: [CategoryID: [PodcastURL]] = [:]
    private static var categories: [TunesCategory] = []
    private static var allPodcasts: [TunesPodcast] {
        return Array(podcastsByURL.values)
    }

    private static var cachedResponse: DirectoryResponse?

    static func fetch(req: Request) throws -> Future<DirectoryResponse> {
        let genresURLString = "http://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres"

        if let cached = cachedResponse {
            // TODO: since podcasts fetch fails for some categories, we could have a
            //       list of failed categories, and then only fetch for those.
            //       If the failed list is empty, then we are truly cached.
            return .map(on: req) { cached }
        }

        return try req.make(Client.self)
            .get(genresURLString)
            // fetch categories first
            .map(to: [TunesCategory].self) { response in
                guard
                    let data = response.http.body.data,
                    let jsonRaw = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let podcastCatsJSON = jsonRaw["26"] as? [String: Any],
                    let topCategoriesJSON = podcastCatsJSON["subgenres"] as? [String: Any]
                    else {
                        throw Abort(.internalServerError)
                }

                let topCategories = categoriesFrom(json: topCategoriesJSON)
                let allCategories = topCategories.reduce([]) { $0 + [$1] + $1.categories }
                return allCategories
        }
            .flatMap(to: DirectoryResponse.self) { categories in
                // Futures for podcasts for each category
                let podcastForCatsFutures: [Future<(TunesCategory, [TunesPodcast])>] = try categories.map { category in
                    return try SearchController.tunesPodcasts(for: category, container: req)
                }
                return podcastForCatsFutures.flatten(on: req) // collect all podcasts for all categories
                    .map(to: DirectoryResponse.self) { res in
                        let allCategories: [TunesCategory] = res.reduce([]) { $0 + [$1.0] }
                        let allPodcastsSet: Set<TunesPodcast> = res.reduce(Set<TunesPodcast>()) { $0.union($1.1) }
                        let allPodcasts: [TunesPodcast] = Array(allPodcastsSet)
                        var categoryPodcastIndices: [CategoryID: [Int]] = [:]
                        for (cat, pods) in res {
                            let filteredIndices = allPodcasts.enumerated()
                                .filter { pods.contains($0.element) }
                                .map { $0.offset }
                            categoryPodcastIndices[cat.id] = filteredIndices
                        }
                        let response = DirectoryResponse(categories: allCategories, podcasts: allPodcasts, categoryPodcasts: categoryPodcastIndices)
                        cachedResponse = response
                        return response
                }
        }
    }

    static func fetchCategories() throws -> [TunesCategory] {
        let genresURLString = "http://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres"
        let contentData = try Data(contentsOf: URL(string: genresURLString)!)

        let json = try JSONSerialization.jsonObject(with: contentData, options: []) as! [String: Any]
        let podcastGenres = json["26"] as! [String: Any]
        let genres = podcastGenres["subgenres"] as! [String: Any]
        return categoriesFrom(json: genres)
    }

    private static func categoriesFrom(json categoriesJSON: [String: Any]) -> [TunesCategory] {
        let result: [TunesCategory] = categoriesJSON.compactMap {
            if let name = ($0.value as? [String: Any])?["name"] as? String {
                if let subJSON = ($0.value as? [String: Any])?["subgenres"] as? [String: Any] {
                    let sub = categoriesFrom(json: subJSON)
                    return TunesCategory(name: name, id: $0.key, categories: sub)
                } else {
                    return TunesCategory(name: name, id: $0.key, categories: [])
                }
            } else {
                return nil
            }
        }
        return result
    }
}
