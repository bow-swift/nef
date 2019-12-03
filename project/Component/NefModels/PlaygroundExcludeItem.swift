//  Copyright © 2019 The nef Authors.

import Foundation

public enum PlaygroundExcludeItem: Equatable {
    case module(name: String)
    case file(name: String, module: String)
}
