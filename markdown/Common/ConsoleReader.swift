import Foundation

protocol ConsoleOutput {
    func printError()
    func printSuccess()
    func printHelp()
}

/// Console output
///
/// - error: show general error. The script fails.
/// - success: show general success. The script finishes successfully.
/// - help: show the help. How to use this script.
enum Console: ConsoleOutput {
    case error
    case success
    case help

    func show() {
        switch self {
        case .error: printError()
        case .success: printSuccess()
        case .help: printHelp()
        }
    }
}


/// Get the parameters from the command line to configure the script.
///
/// In case the parameters are not correct or are incompleted it won't return anything.
///
/// - Returns: the parameters to configure the script: path to parser file and output path for render.
func arguments(keys: String...) -> [String: String] {
    var result: [String: String] = [:]

    func int8Ptr(fromString str: String) -> UnsafePointer<Int8>? {
        let data = str.data(using: .utf8)
        let ptr: UnsafePointer<Int8>? = data?.withUnsafeBytes { $0 }
        return ptr
    }

    var longopts: [option] {
        let lopts: [option] = keys.enumerated().map { (arg) -> option in

            let (offset, element) = arg
            return option(name: int8Ptr(fromString: element),
                          has_arg: required_argument,
                          flag: nil,
                          val: Int32(offset))
        }

        return lopts + [option()]
    }

    let optLongKey = keys.map { key in String(key[key.startIndex]) }.joined(separator: "")

    while case let opt = getopt_long(CommandLine.argc, CommandLine.unsafeArgv, "\(optLongKey):", longopts, nil), opt != -1 {
        let match = keys.enumerated().first { (index, _) in opt == Int32(index) }
        if let key = match?.element {
            result[key] = String(cString: optarg)
        }
    }

    return result
}
