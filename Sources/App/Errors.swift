//
//  Errors.swift
//  App
//
//  Created by Raheel Ahmad on 4/27/18.
//

import Foundation
import Vapor

enum APIFailure: String, AbortError {
    case feedFetch

    var status: HTTPResponseStatus {
        return .internalServerError
    }

    var reason: String {
        switch self {
        case .feedFetch: return "Could not find that Podcast"
        }
    }

    var identifier: String { return rawValue }
}

enum ParsingError: String, AbortError {
    case xml

    var status: HTTPResponseStatus {
        return .internalServerError
    }

    var identifier: String { return rawValue }

    var reason: String {
        switch self {
        case .xml:
            return "Could not parse that Podcast feed"
        }
    }
}

enum DBError: String, AbortError {
    var status: HTTPResponseStatus {
        return .internalServerError
    }

    var reason: String {
        switch self {
        case .idNotFound: return "Could not find that Podcast"
        }
    }

    var identifier: String { return rawValue }

    case idNotFound
}

