//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum CompilerShellError: Error {
    case notFound(command: String, info: String = "")
    case failed(command: String, info: String = "")
}

extension CompilerShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound(let command, let info):
            return "command '\(command)' not found".appending(error: info)
            
        case .failed(let command, let info):
            return "command '\(command)' failed".appending(error: info)
        }
    }
}
