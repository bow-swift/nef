//  Copyright © 2019 The nef Authors.

import Foundation

public enum PlaygroundShellError: Error {
    case empty(directory: String)
    case dependencies(package: String)
    case describe(repository: String)
    case linkPath(item: String)
}

extension PlaygroundShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty(let directory):
            return "directory '\(directory)' is empty"
        case .dependencies(let package):
            return "could not resolve dependencies in package '\(package)'"
        case .describe(let repository):
            return "could not get information from repository '\(repository)'"
        case .linkPath(let item):
            return "could not follow symbolic links to item '\(item)'"
        }
    }
}
