//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct CompilerCommand: ParsableCommand {
    public static var commandName: String = "nefc"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Compile nef Playground")
    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to compile", valueName: "nef playground"))
    var project: ArgumentPath
    
    @ArgumentParser.Flag(name: .customLong("use-cache"), help: "Use cached dependencies if it is possible")
    var cached: Bool

    
    public func run() throws {
        try run().provide(ConsoleProgressReport())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<ProgressReport, nef.Error, Void> {
        nef.Compiler.compile(nefPlayground: project.url, cached: cached)
            .finish()
    }
}
