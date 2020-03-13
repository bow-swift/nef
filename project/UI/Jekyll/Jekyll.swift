//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct JekyllCommand: ParsableCommand {
    public static var commandName: String = "nef-jekyll"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Render Markdown files that can be consumed from Jekyll to generate a microsite")

    public init() {}
    
    @ArgumentParser.Option(help: "Path to the Xcode Playground to render")
    private var project: ArgumentPath
    
    @ArgumentParser.Option(help: "Path where the resulting jekyll files will be generated")
    private var output: ArgumentPath
    
    @ArgumentParser.Option(name: .customLong("main-page"), default: "README.md", help: "Path to 'README.md' file to be used as the index page")
    private var mainPage: String
    
    private var mainURL: URL {
        mainPage == "README.md" ? output.url.appendingPathComponent("README.md")
                                : URL(fileURLWithPath: mainPage.trimmingEmptyCharacters.expandingTildeInPath)
    }
    
    public func run() throws {
        try nef.Jekyll.render(playgroundsAt: project.url, mainPage: mainURL, into: output.url)
                .provide(Console.default)^
                .foldM({ _ in Console.default.exit(failure: "rendering Xcode Playgrounds from '\(self.project.path)'") },
                       { _ in Console.default.exit(success: "rendered Xcode Playgrounds in '\(self.output.path)'")   })^
                .unsafeRunSync()
    }
}
