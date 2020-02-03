//  Copyright © 2020 The nef Authors.

import Foundation

public enum CompilerSystemError: Error {
    case code(String)
    case dependencies(URL, info: String = "")
    case build(URL, info: String = "")
}

extension CompilerSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .code(_):
            return "Could not compile code."
        case .dependencies(let url, let info):
            return "Could not resolve dependencies '\(url.path)' \(info.isEmpty ? "" : info.description.firstCapitalized)"
        case .build(let url, let info):
            return "Could not build '\(url.path)' \(info.isEmpty ? "" : info.description.firstCapitalized)"
        }
    }
}
