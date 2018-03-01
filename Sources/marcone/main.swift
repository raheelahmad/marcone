import Foundation
import Vapor
import SWXMLHash

import PostgreSQL

struct Podcast {
    let title: String
    let podDescription: String?
    let imageURLStr: String?
    let pubDateStr: String?
}

extension Podcast {
    init?(xml: XMLIndexer) {
        let xmlChildren = xml.children
        let titleText = xmlChildren.filter { $0.element?.name == "title" }.first?.element?.text
        guard let title = titleText else { return nil }

        self.title = title
        self.pubDateStr = ""
        self.podDescription = ""
        self.imageURLStr = ""
    }
}

func fetchAndParse(contents: String) -> Podcast? {
    //    let url = URL(string: "http://exponent.fm/feed/")!

    let xml = SWXMLHash.parse(contents)
    //    let names = ["item", "title", "description"]
    let podcastXML = xml.children.first!.children.first!
    return Podcast(xml: podcastXML)
    //        .filter { names.contains($0.element!.name) }
    //    values.first
    //
    //    values[values.count - 2]
}


let drop = try? Droplet()
drop?.get("/") { _ in
    if let dir = drop?.config.workDir, let xmlStr = try? String(contentsOfFile: "\(dir)/Resources/podcast.xml", encoding: .utf8) {
        if let podcast = fetchAndParse(contents: xmlStr) {
            print(podcast)
        }
    }
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
_ = try? drop?.run()
