//
//  DB.swift
//  marconePackageDescription
//
//  Created by Raheel Ahmad on 3/2/18.
//

import Foundation
import Vapor
import PostgreSQL

enum DatabaseError: Error {
    case podcastInsertion
}

struct InsertRequest {
    enum OnConflict {
        case none
        case doNothing
        case update(conflicting: [String], updateKeys: [String])
    }

    let db: PostgreSQL.Connection
    let table: String
    let valueDict: [String: Any]
    let returning: [String]
    let onConflict: OnConflict
    init(db: PostgreSQL.Connection, table: String, valueDict: [String: Any],
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
func insertWith(request: Request, insertRequest: InsertRequest) throws -> [String: Node] {
    let returns = insertRequest.returning.count > 0
    let prequel = "INSERT INTO \(insertRequest.table)"
    let existingValues: [(String, String)] = insertRequest.valueDict.flatMap {
        let _value = $0.value
        let value: String
        if let string = _value as? String {
            value = "$$\(string)$$"
        } else if let date = _value as? Date {
            value = "to_timestamp(\(Int(date.timeIntervalSince1970)))"
        } else if let array = _value as? [String] {
            // only supporting string arrays, o/w will need recursive call here for element
            value = "$${\(array.joined(separator: ", "))}$$"
        } else {
            value = "\(_value)"
        }
        return ($0.key, value)
    }
    let columns = existingValues.map { $0.0 }.joined(separator: ", ")
    let values = existingValues.map { $0.1 }.joined(separator: ", ")

    let returning = returns ? "RETURNING " + insertRequest.returning.joined(separator: ", ") : ""

    var onConflictString: String {
        switch insertRequest.onConflict {
        case .none: return ""
        case .doNothing: return "ON CONFLICT DO NOTHING"
        case let .update(conflicting, updating):
            let conflict = conflicting.joined(separator: ", ")
            let updateSet = existingValues.filter { updating.contains($0.0) }
            let columns = updateSet.map { $0.0 }.joined(separator: ", ")
            let values = updateSet.map { $0.1 }.joined(separator: ", ")
            if updateSet.count > 1 {
                return "ON CONFLICT (\(conflict)) DO UPDATE SET (\(columns)) = (\(values))"
            } else {
                return "ON CONFLICT (\(conflict)) DO UPDATE SET \(columns) = \(values)"
            }
        }
    }

    let statement = [prequel, "(\(columns))", "VALUES", "(\(values))", onConflictString, returning].joined(separator: " ")
    let res: Future<String> = request.withConnection(to: .psql) { connection in
        return "MEOW"
    }

//    print("INSERTING: \(statement)")
//    let m = try insertRequest.db.execute(statement)
//    return m.array?.first?.object ?? [:]
}


