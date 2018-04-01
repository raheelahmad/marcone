//
//  DirectoryRefreshCommand.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/31/18.
//

import Foundation
import Console
import Vapor

import marconeLib

final class DirectoryRefreshCommand: Command, ConfigInitializable {
    let id = "refresh-directory"

    let console: ConsoleProtocol
    let log: LogProtocol
    let workDir: String

    required init(config: Config) throws {
        console = try config.resolveConsole()
        log = try config.resolveLog()
        workDir = config.workDir
    }

    func run(arguments: [String]) throws {
        log.info("Will start refreshing directory in 6 seconds")
        sleep(6)
        try refresh()
    }

    func refresh() throws {
        _ = try DirectoryFetchController.fetch(workDir: workDir)
    }
}
