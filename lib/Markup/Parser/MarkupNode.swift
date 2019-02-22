import Foundation

indirect enum Node: Equatable {
    case nef(command: Nef.Command, [Node])
    case markup(description: String?, String)
    case code(String)
    case raw(String)
    case unknown(String)

    var string: String {
        switch self {
        case let .nef(_, nodes): return nodes.map { $0.string }.joined()
        case let .markup(_, description): return description
        case let .code(code): return code
        case let .raw(line): return line
        case let .unknown(description): return description
        }
    }

    var isRaw: Bool {
        switch self {
        case .raw: return true
        default: return false
        }
    }
}

enum Nef {
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
