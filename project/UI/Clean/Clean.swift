//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct CleanCommand: ParsableCommand {
    public static var commandName: String = "nef-clean"
    public static var configuration =
        CommandConfiguration(
            commandName: commandName,
            abstract: "Clean up nef Playground")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to clean up", valueName: "nef Playground"))
    private var project: ArgumentPath
    

    public func run() throws {
        try run().provide(ConsoleReport())^.unsafeRunSync()
    }
    
    func run<D: ProgressReport & OutcomeReport>() -> EnvIO<D, nef.Error, Void> {
        nef.Clean.clean(nefPlayground: project.url)
            .outcomeScope()
            .reportOutcome(
                success: { _ in
                    "'\(self.project.url.lastPathComponent)' clean up successfully"
                },
                failure: { _ in
                    "clean up nef Playground '\(self.project.url.lastPathComponent)'"
                })
            .finish()
    }
}
