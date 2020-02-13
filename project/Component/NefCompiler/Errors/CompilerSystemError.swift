//  Copyright © 2020 The nef Authors.

import Foundation

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
            return "resolving dependencies \(url?.path ??  "") \(info.isEmpty ? "" : info.description.firstCapitalized)"
        case .build(let url, let info):
            return "building \(url?.path ??  "file") \(info.isEmpty ? "" : info.description.firstCapitalized)"
        }
    }
}
