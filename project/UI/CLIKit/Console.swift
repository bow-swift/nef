//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects
import ArgumentParser

extension ParsableCommand {
    func runIO() -> IO<Swift.Error, ParsableCommand> {
        IO.invoke { try self.run() }.map { _ in self }^
    }
    
    func exit(when condition: (ParsableCommand) -> Bool) -> IO<Swift.Error, ParsableCommand> {
        if condition(self) { return runIO().flatMap { _ in IO.raiseError(Console.Error.arguments(info: ""))^ }^ }
        else { return IO.pure(self)^ }
    }
}

public enum Console {
    case `default`
    
    public func readArguments<A: ParsableCommand>(_ parsableCommand: A.Type) -> IO<Console.Error, A> {
        let parseCommandsIO = IO<Swift.Error, ParsableCommand>.invoke { try parsableCommand.parseAsRoot() }
        let isHelpParsableCommand = { (parsableCommand: ParsableCommand) -> Bool in !(parsableCommand is A) }
        
        return parseCommandsIO
            .flatMap { $0.exit(when: isHelpParsableCommand) }
            .map { $0 as! A }^
            .mapError { (e: Swift.Error) -> Console.Error in
                let info: String
                if let e = e as? Console.Error {
                    info = "\(e)"
                } else {
                    info = parsableCommand.fullMessage(for: e)
                }
                
                return Console.Error.arguments(info: info)
            }^
    }
    
    public func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        ConsoleIO.print(message(), separator: " ", terminator: "\n")
    }
    
    public func help<A>(_ helpMessage: @escaping @autoclosure () -> String) -> IO<Console.Error, A> {
        print(message: helpMessage())
            .map { _ in Darwin.exit(-2) }^
    }
    
    public func exit<A>(failure: String) -> IO<Console.Error, A> {
        print(message: "☠️ ".bold.red + "\(failure)")
            .map { _ in Darwin.exit(-1) }^
        
    }
    
    public func exit<A>(success: String) -> IO<Console.Error, A> {
        print(message: "🙌 ".bold.green + "\(success)")
            .map { _ in Darwin.exit(0) }^
    }
    
    
    /// Kind of errors in ConsoleIO
    public enum Error: Swift.Error, CustomStringConvertible {
        case arguments(info: String)
        case render(info: String = "")
        
        public var description: String {
            switch self {
            case .arguments(let info):
                return info
            case .render(let info):
                return info.isEmpty ? "" : "Render failure: \(info.lightRed)"
            }
        }
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
