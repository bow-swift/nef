//  Copyright © 2019 The nef Authors.

import Foundation

extension Node {
    
    var isHidden: Bool {
        switch self {
        case let .nef(command, _): return command == .hidden
        default: return false
        }
    }
}
