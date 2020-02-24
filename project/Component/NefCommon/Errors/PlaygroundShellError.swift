//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum NefPlaygroundSystemError: Error {
    case template(info: String = "")
    case dependencies(info: String = "")
    case linking(info: String = "")
    case clean(info: String = "")
}

extension NefPlaygroundSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .template(let info):
            return "creating nef playground template".appending(error: info)
        case .dependencies(let info):
            return "resolving nef playground dependencies".appending(error: info)
        case .linking(let info):
            return "linking playground into workspace".appending(error: info)
        case .clean(let info):
             return "clean up nef playground".appending(error: info)
        }
    }
}
