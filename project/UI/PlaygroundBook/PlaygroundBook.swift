//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct PlaygroundBookCommand: ParsableCommand {
    public static var commandName: String = "nef-playground-book"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Build a playground compatible with iPad and 3rd-party libraries")
    
    public init() {}
    
    @ArgumentParser.Option(help: "Name for the Swift Playground. ex. `nef`")
    private var name: String

    @ArgumentParser.Option(help: ArgumentHelp("Path to Package.swift file. ex. `/home/Package.swift`", valueName: "package path"))
    private var package: ArgumentPath

    @ArgumentParser.Option(help: ArgumentHelp("Path where Playground Book will be generated. ex. `/home`", valueName: "output path"))
    private var output: ArgumentPath
    
    private var projectName: String { name.trimmingEmptyCharacters }
    private var packageContent: String? { try? String(contentsOfFile: package.path) }
    
    
    public func run() throws {
        try run().provide(ConsoleProgressReport())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<ProgressReport, nef.Error, Void> {
        nef.SwiftPlayground.render(package: package.url, name: name, output: output.url)
            .reportOutcome(
                failure: "rendering Playground Book",
                success: { url in
                    "rendered Playground Book in '\(url.path)'"
                })
            .finish()
    }
}
