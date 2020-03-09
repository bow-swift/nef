//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefCarbon
import Bow
import BowEffects

struct CarbonCommand: ConsoleCommand {
    static var commandName: String = "nef-carbon"
    static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Generates Carbon code snippets")

    @ArgumentParser.Option(help: "Path to the nef Playground to render")
    var project: String
    
    @ArgumentParser.Option(help: "Path where the resulting carbon files will be generated")
    var output: String
    
    @ArgumentParser.Option(default: "nef", help: "Background color in hexadecimal")
    var background: String
    
    @ArgumentParser.Option(default: .dracula, help: "Carbon theme")
    var theme: CarbonStyle.Theme
    
    @ArgumentParser.Option(default: .x2, help: "export file size [1-5]")
    var size: CarbonStyle.Size
    
    @ArgumentParser.Option(default: .firaCode, help: "Carbon font type")
    var font: CarbonStyle.Font
    
    @ArgumentParser.Option(default: true, help: ArgumentHelp("Shows/hides lines of code [true | false]", valueName: "show-lines"))
    var lines: Bool
    
    @ArgumentParser.Option(default: true, help: ArgumentHelp("Shows/hides the watermark [true | false]", valueName: "show-watermark"))
    var watermark: Bool
    
    var projectURL: URL { URL(fileURLWithPath: project.trimmingEmptyCharacters.expandingTildeInPath) }
    var outputURL: URL  { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
}

@discardableResult
public func carbon(commandName: String) -> Either<CLIKit.Console.Error, Void> {
    CarbonCommand.commandName = commandName
    
    func arguments(parsableCommand: CarbonCommand) -> IO<CLIKit.Console.Error, (input: URL, output: URL, style: CarbonStyle)> {
        guard let backgroundColor = CarbonStyle.Color(hex: parsableCommand.background) ?? CarbonStyle.Color(default: parsableCommand.background) else {
            return IO.raiseError(.arguments(info: "invalid background color"))^
        }
        
        return IO.pure((input: parsableCommand.projectURL,
                        output: parsableCommand.outputURL,
                        style: CarbonStyle(background: backgroundColor,
                                           theme: parsableCommand.theme,
                                           size: parsableCommand.size,
                                           fontType: parsableCommand.font,
                                           lineNumbers: parsableCommand.lines,
                                           watermark: parsableCommand.watermark)))^
    }
    
    return CLIKit.Console.default.readArguments(CarbonCommand.self)
        .flatMap(arguments)
        .flatMap { (input, output, style) in
            nef.Carbon.render(playgroundsAt: input, style: style, into: output)
                .provide(Console.default)^
                .mapError { _ in .render() }
                .foldM({ _ in Console.default.exit(failure: "rendering carbon files from nef Playground at '\(input.path)'") },
                       { _ in Console.default.exit(success: "rendering carbon files from nef Playground at '\(output.path)'")   }) }^
        .reportStatus(in: .default)
        .unsafeRunSyncEither()
}
