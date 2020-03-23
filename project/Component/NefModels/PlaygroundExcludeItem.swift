//  Copyright © 2019 The nef Authors.

import Foundation

/// Models a dependency to exclude from `Swift Package`.
///
/// - module(name:): the module to exclude from dependencies.
/// - file(name:module): the filename to exclude from dependencies.
public enum PlaygroundExcludeItem: Equatable {
    case module(name: String)
    case file(name: String, module: String)
}
