//  Copyright © 2019 The nef Authors.

import Foundation

/// Models a dependency to exclude from `Swift Package`.
public enum PlaygroundExcludeItem: Equatable {
    /// The module to exclude from dependencies.
    case module(name: String)
    
    /// The filename to exclude from dependencies.
    case file(name: String, module: String)
}
