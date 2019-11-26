//  Copyright © 2019 The nef Authors.

import Foundation

enum PlaygroundBookError: Error, CustomStringConvertible {
    case manifest
    case invalidModule
    case page
    case resource
    
    var description: String {
        switch self {
        case .manifest:
            return "could not create manifiest"
        case .invalidModule:
            return "invalid module"
        case .page:
            return "could not create page"
        case .resource:
            fatalError()
        }
    }
}
