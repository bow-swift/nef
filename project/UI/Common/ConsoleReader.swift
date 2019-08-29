//  Copyright © 2019 The nef Authors.

import Foundation

/// Console
///
/// - error: show general error. The script fails.
/// - success: show general success. The script finishes successfully.
/// - help: show the help. How to use this script.
public protocol Console {
    func printError(information: String)
    func printSuccess()
    func printHelp()
}

public extension Console {
    func printSuccess() {
        print("RENDER SUCCEEDED")
    }
    
    func printLog(step information: String) {
        print(information, separator: " ", terminator: "")
    }
    
    func printLog(substep information: String) {
        print("\t\(information)", separator: " ", terminator: "\n")
    }
    
    func printLog(status: Bool) {
        print(" \(status ? "✅" : "❌")", separator: "", terminator: "\n")
    }
}

/// Get the parameters from the command line to configure the script.
///
/// In case the parameters are not correct or are incompleted it won't return anything.
///
/// - Returns: the parameters to configure the script: path to parser file and output path for render.
public func arguments(keys: String...) -> [String: String] {
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
        guard let key = match?.element else { return [:] }

        result[key] = String(cString: optarg)
    }

    return result
}
