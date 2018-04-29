//
//  PodcastFetchController.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/4/18.
//

import Foundation
import SWXMLHash
import Vapor

final class PodcastFetchController {
    private static var unpersistedPodcasts: [String: Podcast] = [:]

    static func podcast(fromURL podcastURLString: String, client: ClientFactoryProtocol) throws -> Podcast {
        if let pod = unpersistedPodcasts[podcastURLString] {
            return pod
        }

        let response = try client.get(podcastURLString)

        guard let contents = response.body.bytes?.makeString() else {
            throw ParsingError.podcast(reason: "could not fetch proper XML from \(podcastURLString)", causes: [])
        }
        print("Trying to make a Podcast now")
        let pod = try podcast(fromString: contents, podcastURLString: podcastURLString)
        unpersistedPodcasts[podcastURLString] = pod
        return pod
    }

    static func podcast(fromString podcastString: String, podcastURLString: String) throws -> Podcast {
        let xml = SWXMLHash.config {
            $0.shouldProcessNamespaces = true
            }.parse(podcastString)

        guard let podcastXML = xml.children.first?.children.first else {
            throw ParsingError.podcast(reason: "Could not find correct XML in \n \(xml.description)", causes: ["Bad XML"])
        }
        print("Ready to parse XML from the child")
        guard let podcast = Podcast(xml: podcastXML, feedFetchURL: podcastURLString) else {
            throw ParsingError.podcast(reason: "Could not construct Podcast struct from URL \(podcastURLString), and XML: \(podcastXML)", causes: ["Bad XML"])
        }
        return podcast
    }
}
