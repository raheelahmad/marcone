//
//  RequestLogger.swift
//  App
//
//  Created by Raheel Ahmad on 5/4/18.
//

import Foundation
import Vapor

public final class RequestLogger: Middleware, Service, ServiceFactory {
    public var serviceType: Any.Type {
        return RequestLogger.self
    }

    public var serviceSupports: [Any.Type] {
        return [RequestLogger.self]
    }

    public func makeService(for worker: Container) throws -> Any {
        return RequestLogger()
    }

    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let logger = try? request.make(PrintLogger.self)
        let startDate = Date()
        logger?.info("»»» \(request.http.method) \(request.http.url.relativeString)")
        return try next.respond(to: request).map(to: Response.self) { res in
            let interval = Date().timeIntervalSince(startDate)
            logger?.info("\(res.http.status.code) \(res.http.status) \(res.http.version) [\(interval) secs.]")
            return res
        }
    }
}

