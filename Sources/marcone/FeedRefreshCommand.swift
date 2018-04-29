//
//  FeedRefreshController.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/7/18.
//

import Foundation
import Dispatch
import Vapor
import Console
import marconeLib

let seedURLs = [
    "http://feeds.gimletmedia.com/hearreplyall",
    "http://feed.thisamericanlife.org/talpodcast",
    "http://www.standup.fm/rss",
    "http://kadavy.libsyn.com/rss",
    "https://rss.art19.com/good-life-project",
    "http://feeds.gimletmedia.com/uncivil",
    "https://huffduffer.com/raheel/rss",
    "http://exponent.fm/feed/",
    "https://www.relay.fm/radar/feed",
    "http://feeds.feedburner.com/Monocle24CultureWithRobBound",
    "http://trackchanges.libsyn.com/rss",
]

final class FeedRefreshCommand: Command, ConfigInitializable {
    let id = "refresh-feed"

    var console: ConsoleProtocol
    let log: LogProtocol

    required init(config: Config) throws {
        console = try config.resolveConsole()
        log = try config.resolveLog()
    }

    func run(arguments: [String]) {
        log.info("Will start refreshing podcasts in 6 seconds")
        sleep(6)
        do {
            let urls = try PodcastsController.allURLs()
            
            let missingURLs = Set(urls).union(seedURLs)
            let client = drop!.client
            
            for url in missingURLs {
                drop?.log.info("Will fetch from \(url)")
                // TODO: this needs to fetch for all podcasts in DB, not just the ones listed above.
                try PodcastsController.addOrUpdate(fromURL: url, client: client)
            }
            self.log.info("Done refreshing")
        } catch let error {
            drop?.log.error("Could not refresh: \(error)")
        }
    }
}
