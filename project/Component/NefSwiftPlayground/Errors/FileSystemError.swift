//  Copyright © 2019 The nef Authors.

import Foundation

public enum FileSystemError: Error {
    case create(item: String)
    case copy(from: String, to: String)
    case remove(item: String)
    case move(from: String, to: String)
    case get(from: String)
    case read(file: String)
    case write(file: String)
    case exist(itemPath: String)
}

extension FileSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .create(let item):
            return "cannot create item '\(item)'"
        case .copy(let from, let to):
            return "cannot copy item at '\(from)' to '\(to)'"
        case .remove(let item):
            return "cannot remove item at '\(item)'"
        case .move(let from, let to):
            return "cannot move item from '\(from)' to '\(to)'"
        case .get(let from):
            return "cannot get items from '\(from)'"
        case .read(let file):
            return "cannot read content of file '\(file)'"
        case .write(let file):
            return "cannot write in file '\(file)'"
        case .exist(let itemPath):
            return "not found item at '\(itemPath)'"
        }
    }
}
