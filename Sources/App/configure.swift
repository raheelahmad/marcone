//
//  configure.swift
//  App
//
//  Created by Raheel Ahmad on 4/23/18.
//

import Foundation
import PostgreSQL
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let serverConfig = EngineServerConfig.default(hostname: "0.0.0.0", port: 8121)
    services.register(serverConfig)

    let dbName = "marcone"
    #if os(Linux)
    let dbConfig = PostgreSQL.PostgreSQLDatabaseConfig(hostname: "db", port: 5432, username: "postgres", database: dbName)
    #else
    let dbConfig = PostgreSQL.PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "postgres", database: dbName)
    #endif

    services.register(dbConfig)
    try services.register(DatabaseKitProvider())
    services.register(PostgreSQLDatabase.self)
    var databases = DatabasesConfig()
    databases.add(database: PostgreSQLDatabase.self, as: .psql)
    services.register(databases)

    var middleware = MiddlewareConfig()
    middleware.use(DateMiddleware.self)
    middleware.use(ErrorMiddleware.self)
    services.register(middleware)
}
