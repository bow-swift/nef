//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum PlaygroundError: Error {
    case structure(info: (Error & CustomStringConvertible)? = nil)
    case template(info: (Error & CustomStringConvertible)? = nil)
    case dependencies(info: (Error & CustomStringConvertible)? = nil)
    case operation(operation: String, info: (Error & CustomStringConvertible)? = nil)
}

extension PlaygroundError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .structure(let e):
            return "creating the nef playground structure".appending(error: e)
        case .template(let e):
            return "download playground template".appending(error: e)
        case .dependencies(let e):
            return "set nef playground dependencies".appending(error: e)
        case .operation(let operation, let e):
            return "could not \(operation) successful".appending(error: e)
        }
    }
}
