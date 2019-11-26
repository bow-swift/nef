//  Copyright © 2019 The nef Authors.

import Foundation

public enum SwiftPlaygroundError: Error {
    case clean(item: String)
    case structure
    case package(packagePath: String)
    case checkout
    case modules(_ paths: [String])
    case playgroundBook(info: String)
    case ioError
    
    public var information: String {
        switch self {
        case .clean(let item):
            return "could not clean item at '\(item)'"
        case .structure:
            return "could not create project structure"
        case .package(let path):
            return "could not build project 'Package.swift' :: \(path)"
        case .checkout:
            return "command 'swift package describe' failed"
        case .modules(let paths):
            let packages = paths.map { $0.filename }.joined(separator: ", ")
            return "could not extract any module from packages: \(packages)"
        case .playgroundBook(let info):
            return "could not create Playground Book (\(info))"
        case .ioError:
            return "failure running IO"
        }
    }
}
