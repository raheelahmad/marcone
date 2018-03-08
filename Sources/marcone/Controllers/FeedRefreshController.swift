//
//  FeedRefreshController.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/7/18.
//

import Foundation
import Vapor
import Console

final class FeedRefreshCommand: Command, ConfigInitializable {
    let id = "refresh"

    var console: ConsoleProtocol
    let log: LogProtocol

    required init(config: Config) throws {
        console = try config.resolveConsole()
        log = try config.resolveLog()
    }

    func run(arguments: [String]) throws {
        log.info("Doing an hourly task")
        let urls = try PodcastDBController.allURLs()
        for url in urls {
            drop?.log.info("Will fetch from \(url)")
            let podcast = try PodcastFetchController.podcast(fromURL: url)
            try PodcastDBController.addOrUpdate(podcast: podcast)
        }
        log.info("Done refreshing")
    }
}
