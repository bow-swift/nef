//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct CleanCommand: ParsableCommand {
    public static var commandName: String = "nef-clean"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Clean up nef Playground")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to nef Playground to clean up")
    private var project: ArgumentPath
    
    
    public func run() throws {
        try nef.Clean.clean(nefPlayground: project.url)
                .provide(Console.default)^
                .foldM({ e in Console.default.exit(failure: "clean up nef Playground '\(self.project.path)'. \(e)") },
                       { _ in Console.default.exit(success: "'\(self.project.path)' clean up successfully")         })^
                .unsafeRunSync()
    }
}
