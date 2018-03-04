//
//  DB.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/2/18.
//

import Foundation
import PostgreSQL

private var df: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    return df
}()

private func db() throws -> PostgreSQL.Connection {
    let dbName = "marcone"
    #if os(Linux)
        let db = try PostgreSQL.Database(hostname: "db", database: dbName, user: "postgres", password: "")
    #else
        let db = try PostgreSQL.Database(hostname: "localhost", database: dbName, user: "postgres", password: "")
    #endif
    let postgres = try db.makeConnection()
    return postgres
}

func insert(podcast: Podcast) throws {
    do {
        let prequel = "INSERT INTO podcasts"
        let valueDict = [
            "url": podcast.url,
            "title": podcast.title,
            "subtitle": podcast.subtitle,
            "description": podcast.podcastDescription,
            "summary": podcast.summary,
            "author_name": podcast.authorName,
            "copyright": podcast.copyright,
            "image_url": podcast.imageURLStr,
            ]
        let existingValues = valueDict.flatMap { $0.value == nil ? nil : ($0.key, "$$\($0.value!)$$") }
        let columns = existingValues.map { $0.0 }.joined(separator: ", ")
        let values = existingValues.map { $0.1 }.joined(separator: ", ")
        let podcastStatement = [prequel, "(\(columns))", "VALUES", "(\(values))"].joined(separator: " ")
        _ = try db().execute(podcastStatement)

        for category in podcast.categories {
            let categoryStatement = "INSERT INTO categories (name) VALUES ($$\(category)$$) ON CONFLICT DO NOTHING"
            _ = try db().execute(categoryStatement)
            let joinStatement = "INSERT INTO podcast_categories (podcast_url, category_name) VALUES ($$\(podcast.url)$$, $$\(category)$$) ON CONFLICT DO NOTHING"
            _ = try db().execute(joinStatement)
        }
    } catch let error {
        throw error
    }
}
