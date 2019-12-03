//  Copyright © 2019 The nef Authors.

import Foundation

public enum PlaygroundShellError: Error {
    case empty(directory: String)
    case dependencies(package: String)
    case describe(repository: String)
    case linkPath(item: String)
}
