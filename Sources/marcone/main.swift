import Foundation
import Vapor

import PostgreSQL
import SWXMLHash

let drop = try? Droplet()
drop?.get("/") { req in
    return ""
}

drop?.post("/add") { req in
    do {
        let cast = try podcast(fromRequest: req)
        try insert(podcast: cast)
        return "Inserted: " + cast.description
    } catch let error {
        throw error
    }
}

_ = try? drop?.run()
