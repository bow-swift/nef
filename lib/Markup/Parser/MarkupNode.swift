import Foundation

indirect enum Node: Equatable {
    enum Code: Equatable {
        case code(String)
        case comment(String)
    }

    enum Nef: Equatable {
        enum Command: String, Equatable {
            case header
            case hidden
            case invalid

            static func get(in line: String) -> Command {
                guard line.contains("nef:") else { return .invalid }
                let commandRawValue = line.clean([" ","\n"]).components(separatedBy: ":").last ?? ""
                return Command(rawValue: commandRawValue) ?? .invalid
            }
        }
    }

    case nef(command: Nef.Command, [Node])
    case markup(description: String?, String)
    case block([Code])
    case raw(String)
}




