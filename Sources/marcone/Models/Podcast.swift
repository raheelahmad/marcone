//
//  Podcast.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash

struct Podcast {
    let url: String
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
    func dictWithoutEpisodes(podcastId: Int?) -> [String: Any] {
        let allDict: [String: Any?] = [
            "url": url,
            "title": title,
            "subtitle": subtitle,
            "description": podcastDescription,
            "summary": summary,
            "author_name": authorName,
            "copyright": copyright,
            "image_url": imageURLStr,
            "id": podcastId
            ]
        return allDict.filter { $0.value != nil }.mapValues { $0! }
    }

    func dictWithEpisodes(podcastId: Int?) -> [String: Any] {
        var allDict = dictWithoutEpisodes(podcastId: podcastId)
        allDict["episodes"] = episodes.map { $0.jsonDict(podcastId: podcastId) }
        return allDict
    }
}

extension Podcast: CustomStringConvertible {
    var description: String { return title + " \(episodes.count) episodes" }
}

extension Podcast {
    init?(xml: XMLIndexer, feedFetchURL: String) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        let _urlAtom: String? = attr("atom:link", attr: "href", in: xmlChildren)
        let _urlAtom10: String? = attr("atom10:link", attr: "href", in: xmlChildren)
        let _urlNewFeed: String? = value("itunes:new-feed-url", in: xmlChildren)
        guard let title = _title else { return nil }
        let url = (_urlAtom ?? _urlAtom10 ?? _urlNewFeed ?? feedFetchURL)
        self.title = title
        self.url = url
        self.podcastDescription = value("description", in: xmlChildren)
        self.summary = value("itunes:summary", in: xmlChildren)
        self.imageURLStr = attr("itunes:image", attr: "href", in: xmlChildren)
        self.authorName = value("itunes:author", in: xmlChildren)
        self.subtitle = value("itunes:subtitle", in: xmlChildren)
        self.copyright = value("copyright", in: xmlChildren)
        self.categories = attrs("itunes:category", attr: "text", in: xmlChildren)

        self.episodes = elements("item", in: xmlChildren).flatMap(Episode.init)
    }
}
