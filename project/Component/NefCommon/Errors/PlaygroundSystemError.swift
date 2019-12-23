//  Copyright © 2019 The nef Authors.

import Foundation

public enum PlaygroundSystemError: Error {
    case name
    case playgrounds(information: String = "")
    case pages(information: String = "")
    case duplicated
    case unknown
}
