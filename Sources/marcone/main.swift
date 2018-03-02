import Foundation
import Vapor

import PostgreSQL
import SWXMLHash

let drop = try? Droplet()
drop?.get("/") { req in
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
    } catch {
        throw Abort.serverError
    }
}

drop?.post("/add") { req in
    do {
        let cast = try podcast(fromRequest: req)
        return cast.description
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
