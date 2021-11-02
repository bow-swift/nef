//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import NefModels
import Bow
import BowEffects
import AppKit

public struct VersionCommand: ParsableCommand {
    public static var commandName: String = "version"
    public static var configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Get the build version number"
    )
    
    public init() {}
    
    
    public func run() throws {
        try run().provide(ConsoleReport())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<ProgressReport, Never, Void> {
        EnvIO { progressReport in
            nef.Version.info()
               .flatMap { version in
                    progressReport.oneShot(VersionEvent.version(version))
               }
        }^.finish()
    }
}

public enum VersionEvent {
    case version(String)
}

extension VersionEvent: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case let .version(version):
            return "Build version number: \(version)"
        }
    }
}
