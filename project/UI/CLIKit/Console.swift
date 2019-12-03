//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects


public struct Console {
    private let scriptName: String
    private let helpMessage: String
    
    public init(script: String, help: String) {
        self.scriptName  = script
        self.helpMessage = help
    }
    
    public func print(message: @escaping @autoclosure () -> String) -> IO<Console.Error, Void> {
        IO.invoke { Swift.print(message(), separator: " ", terminator: "\n") }
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
    public func arguments(keys: [String]) -> IO<Console.Error, [String: String]> {
        IO.invoke {
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

            if result.count == keys.count { return result }
            else { throw Console.Error.arguments }
        }
    }
    
    /// Kind of errors in ConsoleIO
    public enum Error: Swift.Error {
        case arguments
        case render
    }
}


/// Defined `NefModel.Console` into `ConsoleIO`
extension Console: NefModels.Console {
    public func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        IO.invoke { Swift.print(information, separator: " ", terminator: "") }
    }
    
    public func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.invoke { information.forEach { item in Swift.print("\t• \(item)", separator: " ", terminator: "\n") } }
    }
    
    public func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        IO.invoke { Swift.print(" \(success ? "✅" : "❌")", separator: "", terminator: "\n") }
    }
    
    public func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        IO.invoke { Swift.print(" \(success ? "(\(information)) ✅" : "(\(information)) ❌")", separator: "", terminator: "\n") }
    }
}
