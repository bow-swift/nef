//  Copyright © 2019 The nef Authors.

import Foundation

public enum SwiftPlaygroundError: Error {
    case structure
    case package(packagePath: String)
    case checkout
    case playgroundBook
    case ioError
    
    public var information: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .package(let path):
            return "could not build project 'Package.swift' :: \(path)"
        case .checkout:
            return "command 'swift package describe' failed"
        case .playgroundBook:
            return "could not create Swift Playground"
        case .ioError:
            return "failure running IO"
        }
    }
}
