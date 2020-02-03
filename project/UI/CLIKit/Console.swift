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
    
    // MARK: -public methods
    public func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        ConsoleIO.print(message(), separator: " ", terminator: "\n")
    }
    
    public func help<A>() -> IO<Console.Error, A> {
        print(message: self.helpMessage)
            .map { _ in Darwin.exit(-2) }^
    }
    
    public func exit<A>(failure: String) -> IO<Console.Error, A> {
        print(message: "☠️  error:\(scriptName.lowercased()) ".bold.red + "\(failure)")
            .map { _ in Darwin.exit(-1) }^
        
    }
    
    public func exit<A>(success: String) -> IO<Console.Error, A> {
        print(message: "🙌 success:\(scriptName.lowercased()) ".bold.green + "\(success)")
            .map { _ in Darwin.exit(0) }^
    }
    
    
    /// Get the parameters from the command line to configure the script.
    ///
    /// In case the parameters are not correct or are incompleted it won't return anything.
    ///
    /// - Returns: the parameters to configure the script: path to parser file and output path for render.
    public func input() -> IO<Console.Error, [String: String]> {
        func getArgumentList() -> IO<Console.Error, [Argument]> {
            IO.invoke {
                let args = self.arguments + [.init(name: "help", placeholder: "", description: "", isFlag: true, default: "false"),
                                             .init(name: "h", placeholder: "", description: "", isFlag: true, default: "false")]
                let keys = args.map { $0.name }
                
                guard Array(Set(keys)).count == keys.count else { throw Console.Error.duplicated }
                return args
            }
        }
        
        func arguments(_ args: [Argument]) -> IO<Console.Error, [String: String]> {
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
                guard let key = match?.element.name else { return IO.raiseError(Console.Error.arguments)^ }
                
                if optarg != nil {
                    result[key] = String(cString: optarg)
                }
            }
            
            let optionals = args.compactMap { $0.default.isEmpty ? nil : ($0.name, $0.default) }
            optionals.forEach { (key, value) in
                guard result[key] == nil else { return }
                result[key] = value
            }
            
            return IO.pure(result)^
        }
        
        func validate(arguments: [String: String], keys: [String]) -> IO<Console.Error, [String: String]> {
            IO.invoke {
                if Bool(arguments["help"] ?? "") ?? false || Bool(arguments["h"] ?? "") ?? false {
                    throw Console.Error.help
                } else if arguments.keys.containsAll(keys) {
                    return arguments
                } else {
                    throw Console.Error.arguments
                }
            }
        }
        
        let options = IOPartial<Console.Error>.var([Argument].self)
        let args = IOPartial<Console.Error>.var([String: String].self)
        let validated = IOPartial<Console.Error>.var([String: String].self)
        
        return binding(
             options <- getArgumentList(),
                args <- arguments(options.get),
           validated <- validate(arguments: args.get, keys: options.get.map { $0.name }),
        yield: validated.get)^
    }
    
    // MARK: internal attributes <helpers>
    private var helpMessage: String {
        let listArguments = arguments.map { arg in arg.displayParameter }.joined(separator: " ")
        let requireds = arguments.filter { $0.isRequired }.map { arg in arg.displayDescription }.joined(separator: "\n")
        let optionals = arguments.filter { !$0.isRequired }.map { arg in arg.displayDescription }.joined(separator: "\n")
        
        if optionals.isEmpty {
            return  """
                    \(scriptName.bold) \(listArguments)
                    
                    \t\(description)
                    
                    \(requireds)
                    
                    """
        } else {
            return  """
                    \(scriptName.bold) \(listArguments)
                    
                    \t\(description)
                    
                    \(requireds)
                    
                    \t\("Options".bold)
                    
                    \(optionals)
                    
                    """
        }
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
                return "do not received the whole required arguments."+" Use".bold+" --help, --h".cyan
            case .render(let info):
                return info.isEmpty ? "Fail the render." : info.lightRed
            }
        }
    }
}


/// Argument representation
extension Console.Argument {
    var displayParameter: String {
        guard isRequired else { return "" }
        
        if isFlag || placeholder.isEmpty {
            return "--\(name)".bold.lightCyan
        } else {
            return "--\(name)".bold.lightCyan+" <\(placeholder)>"
        }
    }
    
    var displayDescription: String {
        let defaultValue = self.default.trimmingEmptyCharacters
        if defaultValue.isEmpty {
            return "\t--\(name)".lightCyan+" \(description)"
        } else {
            return "\t--\(name)".lightCyan+" \(description)"+" [default: ".dim.lightMagenta+defaultValue.lightMagenta+"]".dim.lightMagenta
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
        ConsoleIO.print(success ? "✓".bold.green + (!information.isEmpty ? "\n> \(information)" : "")
                                : "✗".bold.red   + (!information.isEmpty ? "\n> \(information)" : ""),
                        separator: "",
                        terminator: "\n")
    }
}

