//  Copyright © 2020 The nef Authors.

import Foundation

public enum Image {
    case data(Data)
    case empty
    
    var isEmpty: Bool {
        switch self {
        case .empty: return true
        default: return false
        }
    }
}
