//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects

public enum Console {
    case `default`
    
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
}

/// Defined `NefModel.Console` into `ConsoleIO`
extension Console: NefModels.Console {
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
