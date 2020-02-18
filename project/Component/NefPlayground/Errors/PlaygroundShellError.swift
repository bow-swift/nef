//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum PlaygroundShellError: Error {
    case template(info: String = "")
    case dependencies(info: String = "")
}

extension PlaygroundShellError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .template(let info):
            return "creating nef playground template".appending(error: info)
        case .dependencies(let info):
            return "resolving nef playground dependencies".appending(error: info)
        }
    }
}
