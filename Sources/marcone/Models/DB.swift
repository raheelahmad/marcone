//
//  DB.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/2/18.
//

import Foundation
import PostgreSQL

enum DatabaseError: Error {
    case podcastInsertion
}

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

struct InsertRequest {
    enum OnConflict {
        case none
        case doNothing
        case update(conflicting: [String], updateKeys: [String])
    }

    let db: PostgreSQL.Connection
    let table: String
    let valueDict: [String: Any?]
    let returning: [String]
    let onConflict: OnConflict
    init(db: PostgreSQL.Connection, table: String, valueDict: [String: Any?],
         onConflict: OnConflict = .none,
         returning: [String] = []
        ) {
        self.db = db
        self.table = table
        self.valueDict = valueDict
        self.onConflict = onConflict
        self.returning = returning
    }
}

@discardableResult
private func insertWith(request: InsertRequest) throws -> [String: Node] {
    let returns = request.returning.count > 0
    let prequel = "INSERT INTO \(request.table)"
    let existingValues: [(String, String)] = request.valueDict.flatMap {
        if let _value = $0.value {
            let value: String
            if let string = _value as? String {
                value = "$$\(string)$$"
            } else if let date = _value as? Date {
                value = "to_timestamp(\(Int(date.timeIntervalSince1970)))"
            } else {
                value = "\(_value)"
            }
            return ($0.key, value)
        } else {
            return nil
        }
    }
    let columns = existingValues.map { $0.0 }.joined(separator: ", ")
    let values = existingValues.map { $0.1 }.joined(separator: ", ")

    let returning = returns ? "RETURNING " + request.returning.joined(separator: ", ") : ""

    var onConflictString: String {
        switch request.onConflict {
        case .none: return ""
        case .doNothing: return "ON CONFLICT DO NOTHING"
        case let .update(conflicting, updating):
            let conflict = conflicting.joined(separator: ", ")
            let updateSet = existingValues.filter { updating.contains($0.0) }
            let columns = updateSet.map { $0.0 }.joined(separator: ", ")
            let values = updateSet.map { $0.1 }.joined(separator: ", ")
            return "ON CONFLICT (\(conflict)) DO UPDATE SET (\(columns)) = (\(values))"
        }
    }
    let statement = [prequel, "(\(columns))", "VALUES", "(\(values))", returning, onConflictString].joined(separator: " ")
//    print("INSERTING: \(statement)")
    let m = try request.db.execute(statement)
    return m.array?.first?.object ?? [:]
}

func insert(podcast: Podcast) throws {
    do {
        let podcastValues = [
            "url": podcast.url,
            "title": podcast.title,
            "subtitle": podcast.subtitle,
            "description": podcast.podcastDescription,
            "summary": podcast.summary,
            "author_name": podcast.authorName,
            "copyright": podcast.copyright,
            "image_url": podcast.imageURLStr,
            ]
        let database = try db()
        let podcastId: Int?
        let res = try database.execute("SELECT id FROM podcasts WHERE url = $1", [podcast.url])[0]
        let existingPodcastId: Int? = try res?.get("id")
        if let existingId = existingPodcastId {
            podcastId = existingId
        } else {
            let podcastInsert = InsertRequest(db: database, table: "podcasts", valueDict: podcastValues, returning: ["id"])
            podcastId = try insertWith(request: podcastInsert)["id"]?.int
        }
        guard let id = podcastId else {
            throw DatabaseError.podcastInsertion
        }
        for category in podcast.categories {
            let categoryInsert = InsertRequest(db: database, table: "categories", valueDict: ["name": category], onConflict: .doNothing)
            try insertWith(request: categoryInsert)
            let joinInsert = InsertRequest(db: database, table: "podcast_categories", valueDict: ["podcast_id": id, "category_name": category], onConflict: .doNothing)
            try insertWith(request: joinInsert)
        }

        for episode in podcast.episodes {
            let pubDateInterval = episode.publicationDate.flatMap(df.date)
            let episodeValues: [String: Any?] = [
                "title": episode.title,
                "description": episode.episodeDescription,
                "guid": episode.guid,
                "image_url": episode.imageURL,
                "pub_date": pubDateInterval,
                "duration": episode.duration,
                "enclosure_type": episode.enclosureType,
                "enclosure_length": episode.enclosureLength,
                "enclosure_url": episode.enclosureURL,
                "podcast_id": id,
            ]
            let onConflictUpdateKeys: [String] = Array(episodeValues.keys.filter { $0 != "guid" })
            let onConflict = InsertRequest.OnConflict.update(conflicting: ["guid"], updateKeys: onConflictUpdateKeys)
            let episodeInsert = InsertRequest(db: database, table: "episodes", valueDict: episodeValues, onConflict: onConflict)
            try insertWith(request: episodeInsert)
        }

    } catch let error {
        throw error
    }
}
