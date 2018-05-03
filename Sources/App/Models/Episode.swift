//
//  Episode.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash
import Core
import Vapor
import PostgreSQL

extension String {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}

extension String {
    var asDurationInt: Int? {
        let comps = components(separatedBy: ":")
        var nums = comps.compactMap { Int($0) }
        let allNums = comps.count == nums.count
        guard allNums, nums.count > 0 else { return nil }
        let secs = nums.popLast()
        let minuteSecs = nums.popLast().map { $0 * 60 }
        let hourSecs = nums.popLast().map { $0 * 3600 }
        return (secs ?? 0) + (minuteSecs ?? 0) + (hourSecs ?? 0)
    }
}

let episodeDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    return df
}()

public struct Enclosure: Content {
    let type: String?
    let lengthString: String?
    let urlString: String?

    enum CodingKeys: String, CodingKey {
        case type
        case lengthString = "length"
        case urlString = "url"
    }
}

struct Episode: Content {
    let title: String
    let link: String?
    let author: String?
    let episodeDescription: String?
    let content: String?
    let publicationDate: Date?
    let guid: String?
    let imageURL: String?
    let duration: Int?
    let enclosure: Enclosure?
    let keywords: [String]
    let podcastId: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case author
        case episodeDescription
        case content
        case publicationDate
        case guid
        case imageURL
        case duration
        case enclosure
        case keywords
        case podcastId
    }

    func dbDict(podcastId providedPodcastId: Int? = nil) -> DBDict {
        let podcastId = providedPodcastId ?? self.podcastId
        let allDict: [String: Any?] = [
            "title": title,
            "description": episodeDescription,
            "link": link,
            "author": author,
            "keywords": keywords.joined(separator: ", "),
            "guid": guid,
            "image_url": imageURL,
            "content": content,
            "pub_date": publicationDate,
            "duration": duration,
            "enclosure_type": enclosure?.type,
            "enclosure_length": enclosure?.lengthString,
            "enclosure_url": enclosure?.urlString,
            "podcast_id": podcastId,
        ]
        return allDict.filter { $0.value != nil }.mapValues { $0! }
    }
}

extension Episode {
    init?(row: [PostgreSQLColumn: PostgreSQLData]) {
        do {
            let _title: String? = try row.firstValue(forColumn: "title")?.decode(String.self)
            guard let title = _title else { return nil }
            self.title = title

            self.episodeDescription = tryOrNil { try row.firstValue(forColumn: "description")?.decode(String.self) }
            self.publicationDate = tryOrNil { try row.firstValue(forColumn: "pub_date")?.decode(Date.self) }
            self.guid = tryOrNil { try row.firstValue(forColumn: "guid")?.decode(String.self) }
            self.imageURL = tryOrNil { try row.firstValue(forColumn: "image_url")?.decode(String.self) }
            self.duration = tryOrNil { try row.firstValue(forColumn: "duration")?.decode(Int.self) }
            let enclosureType: String? = tryOrNil { try row.firstValue(forColumn: "enclosure_type")?.decode(String.self) }
            let enclosureLength: String? = tryOrNil { try row.firstValue(forColumn: "enclosure_length")?.decode(String.self) }
            let enclosureURL: String? = tryOrNil { try row.firstValue(forColumn: "enclosure_url")?.decode(String.self) }
            self.enclosure = Enclosure(type: enclosureType, lengthString: enclosureLength, urlString: enclosureURL)
            self.podcastId = tryOrNil { try row.firstValue(forColumn: "podcast_id")?.decode(Int.self) }
            self.link = tryOrNil { try row.firstValue(forColumn: "link")?.decode(String.self) }
            self.author = tryOrNil { try row.firstValue(forColumn: "author")?.decode(String.self) }
            let keywords: String? = tryOrNil { try row.firstValue(forColumn: "keywords")?.decode(String.self) }
            self.keywords = keywords?.components(separatedBy: ", ") ?? []

            self.content = tryOrNil { try row.firstValue(forColumn: "content")?.decode(String.self) }
        } catch {
            print("Failed constructing an Episode from DB row: \(error)")
            return nil
        }
    }
}

extension Episode {
    init?(xml: XMLIndexer) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        guard let title = _title else { return nil }
        self.title = title
        self.episodeDescription = value("description", in: xmlChildren) ?? value("summary", in: xmlChildren)
        self.publicationDate = value("pubDate", in: xmlChildren).flatMap { episodeDateFormatter.date(from: $0) }
        self.link = value("link", in: xmlChildren)
        self.guid = value("guid", in: xmlChildren)

        let image = attr("image", attr: "href", in: xmlChildren)
        let thumbnail = attr("thumbnail", attr: "url", in: xmlChildren)
        self.imageURL = image ?? thumbnail

        self.duration = value("duration", in: xmlChildren)?.asDurationInt
        let enclosureType = attr("enclosure", attr: "type", in: xmlChildren)
        let enclosureLength = attr("enclosure", attr: "length", in: xmlChildren)
        let enclosureURL = attr("enclosure", attr: "url", in: xmlChildren)
        self.enclosure = Enclosure(type: enclosureType, lengthString: enclosureLength, urlString: enclosureURL)
        self.content = value("encoded", in: xmlChildren)
        self.author = value("author", in: xmlChildren)
        self.podcastId = nil
        let keywordsStr: String? = value("keywords", in: xmlChildren)
        self.keywords = keywordsStr.map { $0.components(separatedBy: ", ") } ?? []
    }
}

