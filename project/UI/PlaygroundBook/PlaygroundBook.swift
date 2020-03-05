//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct PlaygroundBookCommand: ParsableCommand {
    static var commandName: String = "nef-playground-book"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Build a Playground Book with 3r-party libraries defined in a Swift Package")

    @ArgumentParser.Option(help: "Name for the Swift Playground. ex. `nef`")
    var name: String

    @ArgumentParser.Option(help: ArgumentHelp("Path to Package.swift file. ex. `/home/Package.swift`", valueName: "package path"))
    var package: String

    @ArgumentParser.Option(help: ArgumentHelp("Path where Playground Bool will be generated. ex. `/home`", valueName: "output path"))
    var output: String
    
    var projectName: String { name.trimmingEmptyCharacters }
    var packagePath: String { package.trimmingEmptyCharacters.expandingTildeInPath }
    var packageContent: String? { try? String(contentsOfFile: packagePath) }
    var outputURL: URL      { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
}

@discardableResult
public func playgroundBook(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    PlaygroundBookCommand.commandName = commandName
    
    func arguments(parsableCommand: PlaygroundBookCommand) -> IO<CLIKit.Console.Error, (packageContent: String, projectName: String, output: URL)> {
        guard let packageContent = parsableCommand.packageContent, !packageContent.isEmpty else {
            return IO.raiseError(.render(info: "invalid Swift Package"))^
        }
    
        return IO.pure((packageContent: packageContent,
                        projectName: parsableCommand.projectName,
                        output: parsableCommand.outputURL))^
    }
        
    return CLIKit.Console.default.readArguments(PlaygroundBookCommand.self)
        .flatMap(arguments)
        .flatMap { (packageContent, projectName, output) in
            nef.SwiftPlayground.render(packageContent: packageContent, name: projectName, output: output)
                .provide(Console.default)^
                .mapError { _ in .render() }
                .foldM({ _   in Console.default.exit(failure: "rendering Playground Book")                  },
                       { url in Console.default.exit(success: "rendered Playground Book in '\(url.path)'")  }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
