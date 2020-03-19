//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public enum CompilerSystemError: Error {
    case code(String)
    case dependencies(URL? = nil, info: String = "")
    case build(URL? = nil, info: String = "")
}

extension CompilerSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .code(_):
            return "compiling code"
        case .dependencies(let url, let info):
            return "resolving dependencies \(url?.path ??  "")".appending(error: info)
        case .build(let url, let info):
            return "building \(url?.path ??  "file")".appending(error: info)
        }
    }
}
