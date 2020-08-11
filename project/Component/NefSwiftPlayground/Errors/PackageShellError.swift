//  Copyright © 2019 The nef Authors.

import Foundation

public enum PackageShellError: Error {
    case empty(directory: String)
    case dumpPackage(package: String, information: String)
    case dependencies(package: String, information: String)
    case describe(repository: String)
    case linkPath(item: String)
}

extension PackageShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty(let directory):
            return "directory '\(directory)' is empty"
        case let .dependencies(package, info):
            return info.isEmpty ? "could not resolve dependencies in the package: '\(package)'" : info.lowercased()
        case .describe(let repository):
            return "could not get information from repository '\(repository)'"
        case .linkPath(let item):
            return "could not follow symbolic links to item '\(item)'"
        case .dumpPackage(let package, let info):
            return info.isEmpty ? "could not get swift package description: '\(package)'" : info.lowercased()
        }
    }
}
