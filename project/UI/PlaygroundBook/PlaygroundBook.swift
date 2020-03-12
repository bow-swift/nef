//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct PlaygroundBookArguments {
    let packageContent: String
    let projectName: String
    let output: URL
}

public struct PlaygroundBookCommand: ConsoleCommand {
    public static var commandName: String = "nef-playground-book"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Build a playground compatible with iPad and 3rd-party libraries")

    public init() {}
    
    @ArgumentParser.Option(help: "Name for the Swift Playground. ex. `nef`")
    var name: String

    @ArgumentParser.Option(help: ArgumentHelp("Path to Package.swift file. ex. `/home/Package.swift`", valueName: "package path"))
    var package: String

    @ArgumentParser.Option(help: ArgumentHelp("Path where Playground Book will be generated. ex. `/home`", valueName: "output path"))
    var output: String
    
    var projectName: String { name.trimmingEmptyCharacters }
    var packagePath: String { package.trimmingEmptyCharacters.expandingTildeInPath }
    var packageContent: String? { try? String(contentsOfFile: packagePath) }
    var outputURL: URL { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                nef.SwiftPlayground.render(packageContent: args.packageContent, name: args.projectName, output: args.output)
                    .provide(Console.default)^
                    .mapError { _ in .render() }
                    .foldM({ e   in Console.default.exit(failure: "rendering Playground Book. \(e)")            },
                           { url in Console.default.exit(success: "rendered Playground Book in '\(url.path)'")  })
                
            }^
    }
    
    private func arguments(parsableCommand: PlaygroundBookCommand) -> IO<CLIKit.Console.Error, PlaygroundBookArguments> {
        guard let packageContent = parsableCommand.packageContent, !packageContent.isEmpty else {
            return IO.raiseError(.arguments(info: "Error: invalid Swift Package"))^
        }
        
        return IO.pure(.init(packageContent: packageContent,
                             projectName: parsableCommand.projectName,
                             output: parsableCommand.outputURL))^
    }
}
