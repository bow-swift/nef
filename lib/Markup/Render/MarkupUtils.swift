import Foundation

extension Node {
    
    var isHidden: Bool {
        switch self {
        case let .nef(command, _): return command == .hidden
        default: return false
        }
    }
}

