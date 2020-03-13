//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct MarkdownCommand: ParsableCommand {
    public static var commandName: String = "nef-markdown"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render Markdown files for given Xcode Playgrounds")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the folder containing Xcode Playground to render")
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting Markdown files will be generated")
    private var output: ArgumentPath
    
    
    public func run() throws {
        try nef.Markdown.render(playgroundsAt: self.project.url, into: self.output.url)
                .provide(Console.default)
                .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(self.project.path)'") },
                       { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(self.output.path)'")     })^
                .unsafeRunSync()
    }
}
