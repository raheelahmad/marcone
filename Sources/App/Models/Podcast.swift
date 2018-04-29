//
//  Podcast.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash
import PostgreSQL
import Vapor

enum PodcastResponse: Content {
    case podcast(Podcast)
    case errorReason(String)

    enum CodingError: Error { case decoding(String) }
    enum CodableKeys: String, CodingKey { case podcast, error }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodableKeys.self)
        if let podcast = try? values.decode(Podcast.self, forKey: .podcast) {
            self = .podcast(podcast)
            return
        }
        if let error = try? values.decode(String.self, forKey: .error) {
            self = .errorReason(error)
        }
        throw CodingError.decoding("Decoding Failed. \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodableKeys.self)
        switch self {
        case .podcast(let podcast):
            try container.encode(podcast, forKey: .podcast)
        case .errorReason(let reason):
            try container.encode(reason, forKey: .error)
        }
    }
}

struct Podcast: Content {
    // Optional so it can represent a non-DB cast.
    // Could make this a DB-only model in which case fetches will go directly to
    // DB, and there won't be an init?(xml:). Faster, but losing some type safety.
    let id: Int?

    let url: String
    let allURLs: [String]
    let title: String
    let subtitle: String?
    let podcastDescription: String?
    let summary: String?
    let authorName: String?
    let copyright: String?
    let imageURLStr: String?
    let categories: [String]

    let episodes: [Episode]

    let averageDuration: Int
    let episodesCount: Int
    let earliestPublishedDate: Date?
    let latestPublishedDate: Date?
}

extension Podcast {
    var dbDict: DBDict {
        let allDict: [String: Any?] = [
            "url": url,
            "all_urls": allURLs,
            "title": title,
            "subtitle": subtitle,
            "description": podcastDescription,
            "summary": summary,
            "author_name": authorName,
            "copyright": copyright,
            "image_url": imageURLStr,
            "id": id,
            "categories": categories.joined(separator: ", ")
        ]
        return allDict.filter { $0.value != nil }.mapValues { $0! }
    }
}

extension Podcast: CustomStringConvertible {
    var description: String { return title + " \(episodes.count) episodes" }
}

extension Podcast {
    init?(row: Row, episodeRows: [Row]? = nil) {
        do {
            let _title: String? = try row.firstValue(forColumn: "title")?.decode(String.self)
            let _url: String? = try row.firstValue(forColumn: "url")?.decode(String.self)
            guard let title = _title, let url = _url else { return nil }
            self.title = title
            self.url = url

            self.id = try row.firstValue(forColumn: "id")?.decode(Int.self)

            self.allURLs = tryOrNil { try row.firstValue(forColumn: "all_urls")?.decode([String].self) } ?? []
            self.subtitle = tryOrNil { try row.firstValue(forColumn: "subtitle")?.decode(String.self) }
            self.podcastDescription = tryOrNil { try row.firstValue(forColumn: "description")?.decode(String.self) }
            self.summary = tryOrNil { try row.firstValue(forColumn: "summary")?.decode(String.self) }
            self.authorName = tryOrNil { try row.firstValue(forColumn: "author_name")?.decode(String.self) }
            self.copyright = tryOrNil {try row.firstValue(forColumn: "copyright")?.decode(String.self) }
            self.imageURLStr = tryOrNil { try row.firstValue(forColumn: "image_url")?.decode(String.self) }

            let categoriesStr: String? = tryOrNil { try row.firstValue(forColumn: "categories")?.decode(String.self) }
            let categories: [String] = tryOrNil { categoriesStr?.components(separatedBy: ", ") } ?? []
            self.categories = categories
            self.averageDuration = tryOrNil { try row.firstValue(forColumn: "average_duration")?.decode(Int.self) }  ?? 0
            self.episodesCount = tryOrNil { try row.firstValue(forColumn: "episodes_count")?.decode(Int.self) } ?? 0
            self.earliestPublishedDate = tryOrNil { try row.firstValue(forColumn: "earliest_published_date")?.decode(Date.self) }
            self.latestPublishedDate = tryOrNil { try row.firstValue(forColumn: "latest_published_date")?.decode(Date.self) }
            self.episodes = episodeRows?.compactMap { Episode(row: $0) } ?? []
        } catch {
            return nil
        }
    }

}

extension Podcast {
    /// Used only in the interim for building a parsed model to be then inserted into DB.
    init?(xml: XMLIndexer, feedFetchURL: String) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        let _urlAtom: String? = attr("link", attr: "href", in: xmlChildren)
        let _urlNewFeed: String? = value("new-feed-url", in: xmlChildren)
        guard let title = _title else { return nil }
        let url = feedFetchURL
        var allURLs = [_urlAtom , _urlNewFeed].compactMap { $0 }
        if !allURLs.contains(feedFetchURL) {
            allURLs.append(feedFetchURL)
        }

        self.id = nil
        self.title = title
        self.url = url
        self.allURLs = allURLs
        self.podcastDescription = value("description", in: xmlChildren)
        self.summary = value("summary", in: xmlChildren)

        let imageFromAttrs = attr("image", attr: "href", in: xmlChildren)
        if let imageFromAttrs = imageFromAttrs {
            self.imageURLStr = imageFromAttrs
        } else if
            let imageElement = elements("image", in: xmlChildren).first,
            let imageURLElement = value("url", in: imageElement.children)
        {
            self.imageURLStr = imageURLElement
        } else {
            self.imageURLStr = nil
        }

        self.authorName = value("author", in: xmlChildren)
        self.subtitle = value("subtitle", in: xmlChildren)
        self.copyright = value("copyright", in: xmlChildren)
        let categoryValues: [String] = nestedValues("category", nestedName: "category", nestedAttribute: "text", in: xmlChildren)
        let categoryAttrs: [String] = attrs("category", attr: "text", in: xmlChildren)
        self.categories = categoryValues + categoryAttrs

        self.episodes = elements("item", in: xmlChildren).compactMap(Episode.init)

        // we could set the correct values, but since this is an interim model to be inserted,
        // and that the final values are provided by the SELECT from DB on access later,
        // we just set 0 values
        self.averageDuration = 0
        self.episodesCount = episodes.count
        self.earliestPublishedDate = nil
        self.latestPublishedDate = nil
    }
}
