//  Copyright © 2019 The nef Authors.

import Foundation

enum PlaygroundBookError: Error, CustomStringConvertible {
    case manifest(path: String)
    case page(path: String)
    
    case invalidModule
    case resource
    
    var description: String {
        switch self {
        case .manifest(let path):
            return "could not create manifiest in '\(path)'"
        case .page(let path):
            return "could not create page at '\(path)'"
            
            
            
        case .invalidModule:
            return "invalid module"
        case .resource:
            fatalError()
        }
    }
}
