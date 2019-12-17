//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects

public struct Console {
    private let scriptName: String
    private let description: String
    private let arguments: [Argument]
    
    public init(script: String, description: String, arguments: Argument...) {
        self.scriptName  = script
        self.description = description
        self.arguments = arguments
    }
    
    // MARK: internal attributes
    private var helpMessage: String {
        let listArguments = arguments.map { arg in "--\(arg.name) <\(arg.placeholder)>" }.joined(separator: " ")
        let information = arguments.map { arg in "\(arg.name): \(arg.description)" }.joined(separator: "\n")
        
        return  """
                \(scriptName) \(listArguments)
                
                \(information)
                
                """
    }
    
    // MARK: -public methods
    public func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        ConsoleIO.print(message(), separator: " ", terminator: "\n")
    }
    
    public func help<A>() -> IO<Console.Error, A> {
        print(message: self.helpMessage)
            .map { _ in Darwin.exit(-2) }^
    }
    
    public func exit<A>(failure: String) -> IO<Console.Error, A> {
        print(message: "☠️ error:\(scriptName.lowercased()): \(failure)")
            .map { _ in Darwin.exit(-1) }^
        
    }
    
    public func exit<A>(success: String) -> IO<Console.Error, A> {
        print(message: "🙌 success:\(scriptName.lowercased()): \(success)")
            .map { _ in Darwin.exit(0) }^
    }
    
    
    /// Get the parameters from the command line to configure the script.
    ///
    /// In case the parameters are not correct or are incompleted it won't return anything.
    ///
    /// - Returns: the parameters to configure the script: path to parser file and output path for render.
    public func input() -> IO<Console.Error, [String: String]> {
        IO.invoke {
            let args = self.arguments + [.init(name: "help", placeholder: "", description: "", isFlag: true, default: "true"),
                                         .init(name: "h", placeholder: "", description: "", isFlag: true, default: "true")]
            let keys = args.map { $0.name }
            let requireds = args.filter { arg in arg.isRequired }.map { $0.name }
            guard Array(Set(keys)).count == keys.count else { throw Console.Error.duplicated }
            
            var result: [String: String] = [:]
            
            var longopts: [option] {
                let lopts: [option] = args.enumerated().map { (offset, element) -> option in
                    return option(name: strdup(element.name),
                                  has_arg: element.isFlag ? no_argument : element.isRequired ? required_argument : optional_argument,
                                  flag: nil,
                                  val: Int32(offset))
                }
                return lopts + [option()]
            }

            let optLongKey = args.map { arg in String(arg.name[arg.name.startIndex]) }.joined(separator: "")
            
            while case let opt = getopt_long(CommandLine.argc, CommandLine.unsafeArgv, "\(optLongKey):", longopts, nil), opt != -1 {
                let match = args.enumerated().first { (index, _) in opt == Int32(index) }
                guard let key = match?.element.name else { throw Console.Error.arguments }

                result[key] = optarg == nil ? "\(key)" : String(cString: optarg)
            }
            
            if result.keys.containsAny(["help", "h"]) {
                throw Console.Error.help
            } else if result.keys.containsAll(requireds) {
                return result
            } else {
                throw Console.Error.arguments
            }
        }^
    }
    
    /// Definition of an argument for Console
    public struct Argument: Equatable {
        let name: String
        let placeholder: String
        let description: String
        let `default`: String
        let isFlag: Bool
        
        var isRequired: Bool {
            self.default.isEmpty
        }
            
        public init(name: String, placeholder: String, description: String, isFlag: Bool = false, default: String = "") {
            self.name = name
            self.placeholder = placeholder
            self.description = description
            self.isFlag = isFlag
            self.default = `default`
        }
    }
    
    /// Kind of errors in ConsoleIO
    public enum Error: Swift.Error, CustomStringConvertible {
        case duplicated
        case arguments
        case help
        case render(information: String = "")
        
        public var description: String {
            switch self {
            case .help:
                return ""
            case .duplicated:
                return "the script has declared duplicated keys."
            case .arguments:
                return "do not received the whole required arguments. For more information, use --help, --h"
            case let .render(info):
                return "fail the render \(info.isEmpty ? "" : "(\(info))")."
            }
        }
    }
}


/// Defined `NefModel.Console` into `ConsoleIO`
extension Console: NefModels.Console {
    public func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        ConsoleIO.print(step.estimatedDuration > .seconds(3) ? "\(information)..." : information,
                        separator: " ",
                        terminator: " ")
    }
    
    public func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        ConsoleIO.print(information.map { item in "\t• \(item)" }.joined(separator: "\n"),
                        separator: " ",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void> {
        ConsoleIO.print(" \(success ? "✅" : "❌")",
                        separator: "",
                        terminator: "\n")
    }
    
    public func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void> {
        ConsoleIO.print(success ? !information.isEmpty ? "(\(information)) ✅" : " ✅"
                                : !information.isEmpty ? "(\(information)) ❌" : " ❌",
                        separator: "",
                        terminator: "\n")
    }
}

