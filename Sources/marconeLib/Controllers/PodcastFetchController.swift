//
//  PodcastFetchController.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation
import SWXMLHash

final class PodcastFetchController {
    private static var unpersistedPodcasts: [URL: Podcast] = [:]

    static func podcast(fromURL podcastURLString: String) throws -> Podcast {
        guard let podcastURL = URL(string: podcastURLString) else {
            throw ParsingError.podcast
        }
        if let pod = unpersistedPodcasts[podcastURL] {
            return pod
        }

        let contents = try String(contentsOf: podcastURL, encoding: .utf8)
        let pod = try podcast(fromString: contents, podcastURLString: podcastURLString)
        unpersistedPodcasts[podcastURL] = pod
        return pod
    }

    static func podcast(fromString podcastString: String, podcastURLString: String) throws -> Podcast {
        let xml = SWXMLHash.config {
            $0.shouldProcessNamespaces = true
            }.parse(podcastString)

        guard
            let podcastXML = xml.children.first?.children.first,
            let podcast = Podcast(xml: podcastXML, feedFetchURL: podcastURLString) else {
            throw ParsingError.podcast
        }
        return podcast
    }
}
