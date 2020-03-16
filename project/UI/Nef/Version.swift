//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct VersionCommand: ParsableCommand {
    public static var commandName: String = "version"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Get the build's version number")
    
    public init() {}
    
    
    public func run() throws {
        try run().provide(ArgumentConsole())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<CLIKit.Console, Never, Void> {
        EnvIO { (console: CLIKit.Console) in
            nef.Version.info()
                .flatMap { version in console.print(message: "Build's version number: \(version)", terminator: " ") }
                .flatMap { _ in console.printStatus(success: true) }
        }^
    }
}

