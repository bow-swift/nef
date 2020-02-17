//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum PlaygroundSystemError: Error {
    case xcworkspaces(information: String = "")
    case playgrounds(information: String = "")
    case pages(information: String = "")
}

extension PlaygroundSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .xcworkspaces(let info):
            return "workspaces operation".appending(error: info)
        case .playgrounds(let info):
            return "playgrounds operation".appending(error: info)
        case .pages(let info):
            return "pages operation".appending(error: info)
        }
    }
}
