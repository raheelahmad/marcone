//
//  main.swift
//  Async
//
//  Created by Raheel Ahmad on 4/17/18.
//

import Foundation
import Service
import Vapor
import App

do {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()

    try App.configure(&config, &env, &services)

    let app = try Application(config: config, environment: env, services: services)
    try app.run()
} catch {
    print("Some error: \(error)")
    exit(1)
}
