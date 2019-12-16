//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects
import BowOptics


public struct Console {
    
    public struct Argument: Equatable, AutoLens {
        let name: String
        let placeholder: String
        let description: String
        let required: Bool
        
        public init(name: String, placeholder: String, description: String, required: Bool) {
            self.name = name
            self.placeholder = placeholder
            self.description = description
            self.required = required
        }
    }
    
    private let scriptName: String
    private let arguments: [Argument]
    
    internal init(script: String, arguments: [Argument]) {
        self.scriptName  = script
        self.arguments = arguments
    }
    
    public init(script: String, arguments: Argument...) {
        self.init(script: script, arguments: arguments)
    }
    
    private var helpMessage: String {
        let listArguments = arguments.map { arg in "--\(arg.name) <\(arg.placeholder)>" }.joined(separator: " ")
        let information = arguments.map { arg in "\(arg.name): \(arg.description)" }.joined(separator: "\n")
        
        return  """
                \(scriptName) \(listArguments)
                
                \(information)
                
                """
    }
    
    public func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        ConsoleIO.print(message(), separator: " ", terminator: "\n")
    }
    
    public func help<A>() -> IO<Console.Error, A> {
        print(message: self.helpMessage)
            .map { _ in Darwin.exit(-1) }^
    }
    
    public func exit<A>(failure: String) -> IO<Console.Error, A> {
        print(message: "☠️ error:\(scriptName.lowercased()): \(failure)")
            .map { _ in Darwin.exit(-1) }^
        
    }
    
    public func exit<A>(success: String) -> IO<Console.Error, A> {
        print(message: "🙌 success:\(scriptName.lowercased()): \(success)")
            .map { _ in Darwin.exit(-1) }^
    }
    
    
    /// Get the parameters from the command line to configure the script.
    ///
    /// In case the parameters are not correct or are incompleted it won't return anything.
    ///
    /// - Returns: the parameters to configure the script: path to parser file and output path for render.
    public func input() -> IO<Console.Error, [String: String]> {
        IO.invoke {
            let required  = self.arguments.filter { arg in arg.required }.map { $0.name }
            let optionals = self.arguments.filter { arg in !arg.required }.map { $0.name }
            let helps = ["help", "h"]
            let keys = required + optionals + helps
            guard keys.containsAll(Array(Set(keys))) else { throw Console.Error.duplicated }
            
            var result: [String: String] = [:]
            
            var longopts: [option] {
                let lopts: [option] = keys.enumerated().map { (offset, element) -> option in
                    return option(name: strdup(element),
                                  has_arg: required_argument,
                                  flag: nil,
                                  val: Int32(offset))
                }
                return lopts + [option()]
            }

            let optLongKey = keys.map { key in String(key[key.startIndex]) }.joined(separator: "")
            
            while case let opt = getopt_long(CommandLine.argc, CommandLine.unsafeArgv, "\(optLongKey):", longopts, nil), opt != -1 {
                let match = keys.enumerated().first { (index, _) in opt == Int32(index) }
                guard let key = match?.element else { throw Console.Error.arguments }

                result[key] = String(cString: optarg)
            }
            
            if result.keys.containsAll(required) {
                return result
            } else if result.keys.containsAny(helps) {
                throw Console.Error.help(message: self.helpMessage)
            } else {
                throw Console.Error.arguments
            }
        }
        .handleErrorWith { error in
            switch error {
            case .help(let message):
                return self.print(message: message).map { _ in Darwin.exit(-1) }
            default:
                return self.exit(failure: "\(error)")
            }
        }^
    }
    
    /// Kind of errors in ConsoleIO
    public enum Error: Swift.Error, CustomStringConvertible {
        case duplicated
        case arguments
        case help(message: String)
        case render
        
        public var description: String {
            switch self {
            case let .help(message): return message
            case .duplicated: return "the script has declared duplicated keys."
            case .arguments: return "do not received the whole required arguments. You can use --help, --h."
            case .render: return "fail the render."
            }
        }
    }
}


/// Defined `NefModel.Console` into `ConsoleIO`
extension Console: NefModels.Console {
    public func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        ConsoleIO.print(information,
                        separator: " ",
                        terminator: " ")
    }
    
    public func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        ConsoleIO.print(information.map { item in "\t• \(item)" }.joined(separator: "\n"),
                        separator: " ",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        ConsoleIO.print(" \(success ? "✅" : "❌")",
                        separator: "",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        ConsoleIO.print(success ? !information.isEmpty ? "(\(information)) ✅" : " ✅"
                                : !information.isEmpty ? "(\(information)) ❌" : " ❌",
                        separator: "",
                        terminator: "\n")
    }
}
