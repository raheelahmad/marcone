//
//  config.swift
//  Async
//
//  Created by Raheel Ahmad on 4/19/18.
//

import Foundation
import Vapor
import Routing
import PostgreSQL

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    let router = EngineRouter.default()
    // TODO: add routes
    // routes(router)
    services.register(router)

    // set up Server config
    let serverConfig = EngineServerConfig.default(hostname: "0.0.0.0", port: 9000)
    services.register(serverConfig)

    // Set up PostgreSQL connection
    let dbConfig = PostgreSQL.PostgreSQLDatabaseConfig(hostname: "127.0.0.1", port: 5432, username: "postgres", database: "marcone" )
    services.register(dbConfig)
    try services.register(DatabaseKitProvider())
    services.register(PostgreSQLDatabase.self)
    var databases = DatabaseConfig()
    databases.add(database: PostgreSQLDatabase.self, as: .psql)
    services.register(databases)

    var middleware = MiddlewareConfig()
    middleware.use(DateMiddleware.self)
    middleware.use(ErrorMiddleware.self)
    services.register(middleware)
}
