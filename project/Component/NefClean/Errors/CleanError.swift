//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum CleanError: Error {
    case clean(info: (Error & CustomStringConvertible)? = nil)
}

extension CleanError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .clean(let e):
            return "clean nef playground structure".appending(error: e)
        }
    }
}

