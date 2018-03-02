import Foundation
import Vapor

import PostgreSQL

let drop = try? Droplet()
drop?.get("/") { _ in
    do {
        let dbName = "marcone"
        #if os(Linux)
        let db = try PostgreSQL.Database(hostname: "db", database: dbName, user: "postgres", password: "")
        #else
        let db = try PostgreSQL.Database(hostname: "localhost", database: dbName, user: "postgres", password: "")
        #endif
        let postgres = try db.makeConnection()
        let res = try postgres.execute("SELECT * FROM podcasts")
        var resultFinal = [String]()
        for item in res.array! {
            if let title: String = try? item.get("title"), let authorName: String = try? item.get("author_name") {
                resultFinal.append("Title: \(title), author name: \(authorName)")
            }
        }
        let result = "Result: \(resultFinal)"
        return result
    } catch let error {
        return error.localizedDescription
    }
}

drop?.get("/add") { _ in
//    let contents = String(contentsOf: URL("http://kadavy.net/podcast-rss")!, encoding: .utf8)
    return ""
}

_ = try? drop?.run()
