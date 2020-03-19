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
                                                           abstract: "Render Markdown files for a given Xcode Playgrounds")

    public init() {}
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to render", valueName: "nef playground"))
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting Markdown files will be generated")
    private var output: ArgumentPath
    
    
    public func run() throws {
        try run().provide(ArgumentConsole())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<CLIKit.Console, nef.Error, Void> {
        nef.Markdown.render(playgroundsAt: self.project.url, into: self.output.url)
            .reportStatus(failure: { e in "rendering Xcode Playgrounds from '\(self.project.path)'" },
                          success: { _ in "rendered Xcode Playgrounds in '\(self.output.path)'" })
    }
}
