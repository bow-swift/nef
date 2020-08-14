//  Copyright © 2019 The nef Authors.

import Foundation

public enum SwiftPlaygroundError: Error {
    case clean(item: String)
    case structure
    case package(packagePath: String)
    case checkout(info: String)
    case modules(_ paths: [String])
    case dumpPackage(info: Error)
    case playgroundBook(info: String)
    case ioError(info: String = "")
    
    public var information: String {
        switch self {
        case .clean(let item):
            return "could not clean item at '\(item)'"
        case .structure:
            return "could not create project structure"
        case .package(let path):
            return "could not build project 'Package.swift' :: \(path)"
        case .checkout(let info):
            return "command checkout failed: \(info)"
        case .modules(let paths):
            let packages = paths.map { $0.filename }.joined(separator: ", ")
            return "could not extract any module from dependencies in your Package.swift: \(packages)"
        case .dumpPackage(let error):
            return error.localizedDescription.isEmpty ? "could not read the Package.swift file" : error.localizedDescription
        case .playgroundBook(let info):
            return "could not create Playground Book: \(info)"
        case .ioError(let info):
            return "failure running IO \(info.isEmpty ? "" : ": \(info)")"
        }
    }
}
