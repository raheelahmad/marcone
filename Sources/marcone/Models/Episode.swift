//
//  Episode.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash
import PostgreSQL

private var df: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    return df
}()

struct Episode {
    let title: String
    let summary: String?
    let episodeDescription: String?
    let publicationDate: String?
    let guid: String?
    let imageURL: String?
    let duration: String?
    let enclosureType: String?
    let enclosureLength: String?
    let enclosureURL: String?
    let podcastId: Int?

    func jsonDict(podcastId providedPodcastId: Int? = nil) -> [String: Any] {
        let pubDateInterval = publicationDate.flatMap(df.date)
        let podcastId = providedPodcastId ?? self.podcastId
        let allDict: [String: Any?] = [
            "title": title,
            "description": episodeDescription,
            "guid": guid,
            "image_url": imageURL,
            "pub_date": pubDateInterval,
            "duration": duration,
            "enclosure_type": enclosureType,
            "enclosure_length": enclosureLength,
            "enclosure_url": enclosureURL,
            "podcast_id": podcastId,
        ]
        return allDict.filter { $0.value != nil }.mapValues { $0! }
    }
}

extension Episode {
    init?(node: Node) {
        guard let title: String = try? node.get("title") else { return nil }
        self.title = title
        self.summary = try? node.get("summary")
        self.episodeDescription = try? node.get("description")
        self.publicationDate = try? node.get("pub_date")
        self.guid = try? node.get("guid")
        self.imageURL = try? node.get("image_url")
        self.duration = try? node.get("duration")
        self.enclosureType = try? node.get("enclosure_type")
        self.enclosureLength = try? node.get("enclosure_length")
        self.enclosureURL = try? node.get("enclosure_url")
        self.podcastId = try? node.get("podcast_id")
    }
}

extension Episode {
    init?(xml: XMLIndexer) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        guard let title = _title else { return nil }
        self.title = title
        self.episodeDescription = value("description", in: xmlChildren)
        self.summary = value("itunes:summary", in: xmlChildren)
        self.publicationDate = value("pubDate", in: xmlChildren)
        self.guid = value("guid", in: xmlChildren)

        let image = attr("itunes:image", attr: "href", in: xmlChildren)
        let thumbnail = attr("media:thumbnail", attr: "url", in: xmlChildren)
        self.imageURL = image ?? thumbnail

        self.duration = value("itunes:duration", in: xmlChildren)
        self.enclosureType = attr("enclosure", attr: "type", in: xmlChildren)
        self.enclosureLength = attr("enclosure", attr: "length", in: xmlChildren)
        self.enclosureURL = attr("enclosure", attr: "url", in: xmlChildren)
        self.podcastId = nil
    }
}

