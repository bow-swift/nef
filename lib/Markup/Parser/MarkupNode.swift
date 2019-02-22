import Foundation

indirect enum Node: Equatable {
    case nef(command: Nef.Command, [Node])
    case markup(title: String?, String)
    case comment(String)
    case code(String)
    case unknown(String)

    var string: String {
        switch self {
        case let .nef(_, nodes): return nodes.map { $0.string }.joined()
        case let .markup(_, description): return description
        case let .comment(description): return description
        case let .code(code): return code
        case let .unknown(description): return description
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
