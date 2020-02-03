//  Copyright © 2019 The nef Authors.

import Foundation

public enum Error: Swift.Error {
    case compiler(info: String = "")
    case markdown(info: String = "")
    case jekyll(info: String = "")
    case carbon(info: String = "")
    case invalidSnapshot(info: String = "")
    case swiftPlaygrond(info: String = "")
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compiler(let info):
            return info.isEmpty ? "Failed the compiler." : info
        case .markdown(let info):
            return info.isEmpty ? "Failed the markdown." : info
        case .jekyll(let info):
            return info.isEmpty ? "Failed the jekyll." : info
        case .carbon(let info):
            return info.isEmpty ? "Failed the carbon." : info
        case .invalidSnapshot(let info):
            return info.isEmpty ? "Invalid snapshot." : info
        case .swiftPlaygrond(let info):
            return info.isEmpty ? "Failed Swift Playground generator." : info
        }
    }
}
