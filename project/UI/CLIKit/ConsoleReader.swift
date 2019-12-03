//  Copyright © 2019 The nef Authors.

import Foundation

/// Protocol to define the `Console Output`
public protocol ConsoleOutput {
    func printError(information: String)
    func printSuccess()
    func printHelp()
}

public extension ConsoleOutput {
    func printSuccess() {
        print("RENDER SUCCEEDED")
    }
}

/// Console
///
/// - error: show general error. The script fails.
/// - success: show general success. The script finishes successfully.
/// - help: show the help. How to use this script.
public enum ConsoleLegacy {
    case error(information: String)
    case success
    case help

    public func show(output console: ConsoleOutput) {
        switch self {
        case let .error(information): console.printError(information: information)
        case .success: console.printSuccess()
        case .help: console.printHelp()
        }
    }
}

public func arguments(keys: String...) -> [String: String] {
    Console(script: "", help: "").arguments(keys: keys).unsafeRunSyncEither().getOrElse([:])
}
