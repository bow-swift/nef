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
    
    @ArgumentParser.Option(help: ArgumentHelp("Path to nef Playground to clean up", valueName: "nef Playground"))
    private var project: ArgumentPath
    

    public func run() throws {
        try run().provide(ConsoleProgressReport())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<ProgressReport, nef.Error, Void> {
        nef.Clean.clean(nefPlayground: project.url)
            .finish(
                onSuccess: CleanCommandOutcome.successful(self.project.path),
                onFailure: { e in
                    CleanCommandOutcome.failed(self.project.path, error: e)
                })
    }
}

enum CleanCommandOutcome {
    case successful(String)
    case failed(String, error: nef.Error)
}

extension CleanCommandOutcome: CustomProgressDescription {
    var progressDescription: String {
        switch self {
        case .successful(let name):
            return "🙌".bold.green + " '\(name)' clean up successfully"
        
        case let .failed(name, error: error):
            return "☠️".bold.red + " clean up nef Playground '\(name)' failed with error: \(error)"
        }
    }
}
