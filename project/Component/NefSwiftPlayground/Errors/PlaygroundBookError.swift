//  Copyright © 2019 The nef Authors.

import Foundation

enum PlaygroundBookError: Error, CustomStringConvertible {
    case manifest(path: String)
    case page(path: String)
    case resource(name: String)
    case invalidModule(name: String)
    case sources(module: String)
    
    var description: String {
        switch self {
        case .manifest(let path):
            return "manifiest in '\(path)'"
        case .page(let path):
            return "page at '\(path)'"
        case .resource(let name):
            return "resource '\(name)'"
        case .invalidModule(let name):
            return "module '\(name)'"
        case .sources(let module):
            return "copy sources to module '\(module)'"
        }
    }
}
