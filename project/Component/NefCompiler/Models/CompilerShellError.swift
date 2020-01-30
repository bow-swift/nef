//  Copyright © 2020 The nef Authors.

import Foundation

public enum CompilerShellError: Error {
    case notFound(command: String, information: String)
}

extension CompilerShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound(let command, let information):
            return "command not found '\(command)'.\(information.isEmpty ? "" : " (\(information))")"
        }
    }
}
