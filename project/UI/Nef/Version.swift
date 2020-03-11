//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct VersionCommand: ConsoleCommand {
    public static var commandName: String = "version"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Get the build's version number")
    
    public init() {}
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        nef.Version.info()
            .mapError { _ in .render() }^
            .flatMap { version in Console.default.print(message: "Build's version number: \(version)", terminator: " ") }^
    }
}
