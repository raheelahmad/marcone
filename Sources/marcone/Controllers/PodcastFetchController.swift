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
        let xml = SWXMLHash.parse(contents)
        let podcastXML = xml.children.first!.children.first!
        guard let podcast = Podcast(xml: podcastXML, feedFetchURL: podcastURLString) else {
            throw ParsingError.podcast
        }
        return podcast
    }
}
