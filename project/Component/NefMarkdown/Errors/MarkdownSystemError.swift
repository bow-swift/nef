//  Copyright © 2019 The nef Authors.

import Foundation

public enum MarkdownSystemError: Error {
    case write(file: String)
    case create(item: URL)
    case remove(item: URL)
}

extension MarkdownSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .write(let file):
            return "cannot write in file '\(file)'"
        case .create(let item):
            return "can not create '\(item.path)'"
        case .remove(let item):
            return "can not delete '\(item.path)'"
        }
    }
}
