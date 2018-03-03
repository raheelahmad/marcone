//
//  DB.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/2/18.
//

import Foundation
import PostgreSQL

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
        let statement = "INSERT INTO podcasts VALUES "
        [
            "url": podcast.url,
            "title": podcast.title,
            "subtitle": podcast.subtitle,
            "description": podcast.podcastDescription,
            "pub_date": podcast.subtitle,
            "subtitle": podcast.subtitle,
            ]
        let res = try db().execute("SELECT * FROM podcasts")
    } catch let error {
        throw error
    }
}
