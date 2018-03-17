//
//  Podcast.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash
import PostgreSQL

struct Podcast {
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
}

extension Podcast {
    func jsonWithoutEpisodes() -> JSON {
        return dbDict
    }

    func jsonWithEpisodes() -> [String: Any] {
        var allDict = jsonWithoutEpisodes()
        allDict["episodes"] = episodes.map { $0.json }
        return allDict
    }

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
    init?(node: Node) {
        let _title: String? = try? node.get("title")
        let _url: String? = try? node.get("url")
        guard let title = _title, let url = _url else { return nil }
        self.title = title
        self.url = url
        self.id = try? node.get("id")
        self.allURLs = (try? node.get("all_urls")) ?? []
        self.subtitle = try? node.get("subtitle")
        self.podcastDescription = try? node.get("description")
        self.summary = try? node.get("summary")
        self.authorName = try? node.get("author_name")
        self.copyright = try? node.get("copyright")
        self.imageURLStr = try? node.get("image_url")

        let categoriesStr: String? = try? node.get("categories")
        let categories: [String] = categoriesStr?.components(separatedBy: ", ") ?? []
        self.categories = categories
        self.episodes = []
    }

    /// When we have fetched everything from the DB, probably for a single Podcast
    init?(node: Node, episodeNodes: [Node]) {
        let _title: String? = try? node.get("title")
        let _url: String? = try? node.get("url")
        guard let title = _title, let url = _url else { return nil }
        self.title = title
        self.url = url
        self.id = try? node.get("id")
        self.allURLs = (try? node.get("all_urls")) ?? []
        self.subtitle = try? node.get("subtitle")
        self.podcastDescription = try? node.get("description")
        self.summary = try? node.get("summary")
        self.authorName = try? node.get("author_name")
        self.copyright = try? node.get("copyright")
        self.imageURLStr = try? node.get("image_url")

        let categories: String? = try? node.get("categories")
        self.categories = categories?.components(separatedBy: ", ") ?? []

        let episodes = episodeNodes.flatMap { Episode.init(node: $0) }
        self.episodes = episodes
    }
}

extension Podcast {
    init?(xml: XMLIndexer, feedFetchURL: String) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        let _urlAtom: String? = attr("link", attr: "href", in: xmlChildren)
        let _urlNewFeed: String? = value("new-feed-url", in: xmlChildren)
        guard let title = _title else { return nil }
        let url = feedFetchURL
        var allURLs = [_urlAtom , _urlNewFeed].flatMap { $0 }
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

        self.episodes = elements("item", in: xmlChildren).flatMap(Episode.init)
    }
}
