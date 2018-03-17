//
//  PodcastFetchController.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation
import SWXMLHash

final class PodcastFetchController {
    static func podcast(fromURL podcastURLString: String) throws -> Podcast {
        guard let podcastURL = URL(string: podcastURLString) else {
            throw ParsingError.podcast
        }
        let contents = try String(contentsOf: podcastURL, encoding: .utf8)
        return try podcast(fromString: contents, podcastURLString: podcastURLString)
    }

    static func podcast(fromString podcastString: String, podcastURLString: String) throws -> Podcast {
        let xml = SWXMLHash.config {
            $0.shouldProcessNamespaces = true
            }.parse(podcastString)
        let podcastXML = xml.children.first!.children.first!
        guard let podcast = Podcast(xml: podcastXML, feedFetchURL: podcastURLString) else {
            throw ParsingError.podcast
        }
        return podcast
    }
}
