//  Copyright © 2019 The nef Authors.

import Foundation

public enum MarkdownSystemError: Error {
    case write(file: String)
}

extension MarkdownSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .write(let file):
            return "cannot write in file '\(file)'"
        }
    }
}
