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
            return "Could not compile code."
        case .dependencies(let url, let info):
            return "Could not resolve dependencies \(url?.path ??  "") \(info.isEmpty ? "" : info.description.firstCapitalized)"
        case .build(let url, let info):
            return "Could not complete build \(url?.path ??  "file") \(info.isEmpty ? "" : info.description.firstCapitalized)"
        }
    }
}
