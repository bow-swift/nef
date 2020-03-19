//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects

public protocol Console: NefModels.Console {
    func print<E: Swift.Error>(message: @escaping @autoclosure () -> String, separator: String, terminator: String) -> IO<E, Void>
    func help<E: Swift.Error>(_ helpMessage: @escaping @autoclosure () -> String) -> IO<E, Void>
    func exit<E: Swift.Error>(failure: String, separator: String, terminator: String) -> IO<E, Void>
    func exit<E: Swift.Error>(success: String, separator: String, terminator: String) -> IO<E, Void>
}

public extension Console {
    func print<E: Swift.Error>(message: @escaping @autoclosure () -> String) -> IO<E, Void> {
        print(message: message(), separator: " ", terminator: "\n")
    }
    
    func print<E: Swift.Error>(message: @escaping @autoclosure () -> String, separator: String) -> IO<E, Void> {
        print(message: message(), separator: separator, terminator: "\n")
    }
    
    func print<E: Swift.Error>(message: @escaping @autoclosure () -> String, terminator: String) -> IO<E, Void> {
        print(message: message(), separator: " ", terminator: terminator)
    }
    
    func exit<E: Swift.Error>(failure: String) -> IO<E, Void> {
        exit(failure: failure, separator: " ", terminator: "\n")
    }
    
    func exit<E: Swift.Error>(success: String) -> IO<E, Void> {
        exit(success: success, separator: " ", terminator: "\n")
    }
}


/// Instance for CLIKit.Console
public struct ArgumentConsole: CLIKit.Console {
    
    public init() { }
    
    //MARK: - protocol <CLIKit.Console>
    public func print<E: Swift.Error>(message: @escaping @autoclosure () -> String, separator: String = " ", terminator: String = "\n") -> IO<E, Void> {
        ConsoleIO.print(message(), separator: separator, terminator: terminator)
    }
    
    public func help<E: Swift.Error>(_ helpMessage: @escaping @autoclosure () -> String) -> IO<E, Void> {
        print(message: helpMessage())
            .map { _ in Darwin.exit(-2) }.void()^
    }
    
    public func exit<E: Swift.Error>(failure: String, separator: String = " ", terminator: String = "\n") -> IO<E, Void> {
        print(message: "☠️".bold.red + " \(failure)", separator: separator, terminator: terminator)
            .map { _ in Darwin.exit(-1) }.void()^
    }
    
    public func exit<E: Swift.Error>(success: String, separator: String = " ", terminator: String = "\n") -> IO<E, Void> {
        print(message: "🙌".bold.green + " \(success)", separator: separator, terminator: terminator)
            .map { _ in Darwin.exit(0) }.void()^
    }
    
    //MARK: - protocol <NefModel.Console>
    public func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        ConsoleIO.print(step.estimatedDuration > .seconds(3) ? "\(information)"+"...".lightGray : information,
                        separator: " ",
                        terminator: " ")
    }
    
    public func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        ConsoleIO.print(information.map { item in "\t• ".lightGray + "\(item)".cyan }.joined(separator: "\n"),
                        separator: " ",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void> {
        ConsoleIO.print(success ? "✓".bold.green : "✗".bold.red,
                        separator: "",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void> {
        let infoFormatted = !information.isEmpty ? "\n\t| \(information.replacingOccurrences(of: ": ", with: "\n\t| "))" : ""
        
        return ConsoleIO.print(success ? "✓".bold.green + infoFormatted
                                       : "✗".bold.red   + infoFormatted,
                               separator: "",
                               terminator: "\n")
    }
}

/// `Console` report status
extension EnvIO where F == IOPartial<nef.Error>, D == NefModels.Console {
    
    public func reportStatus(failure: @escaping (nef.Error) -> String, success: @escaping (A) -> String) -> EnvIO<CLIKit.Console, nef.Error, Void> {
        contramap { (console: CLIKit.Console) in console }
            .foldM({ e in self.reportFailure(failure(e)) },
                   { a in self.reportSuccess(success(a)) })
    }
    
    private func reportFailure(_ failure: String) -> EnvIO<CLIKit.Console, nef.Error, Void> {
        EnvIO { console in
            console.exit(failure: failure)
        }^
    }
    
    private func reportSuccess(_ success: String) -> EnvIO<CLIKit.Console, nef.Error, Void> {
        EnvIO { console in
            console.exit(success: success)
        }^
    }
}
