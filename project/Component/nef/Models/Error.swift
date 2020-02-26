//  Copyright © 2019 The nef Authors.

import Foundation

public enum Error: Swift.Error {
    case compiler(info: String = "")
    case markdown(info: String = "")
    case jekyll(info: String = "")
    case carbon(info: String = "")
    case invalidSnapshot(info: String = "")
    case playground(info: String = "")
    case swiftPlaygrond(info: String = "")
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compiler(let info):
            return info.isEmpty ? "Compiler failure." : info
        case .markdown(let info):
            return info.isEmpty ? "Markdown failure." : info
        case .jekyll(let info):
            return info.isEmpty ? "Jekyll failure." : info
        case .carbon(let info):
            return info.isEmpty ? "Carbon failure." : info
        case .invalidSnapshot(let info):
            return info.isEmpty ? "Invalid snapshot." : info
        case .playground(let info):
            return info.isEmpty ? "Playground generator failure." : info
        case .swiftPlaygrond(let info):
            return info.isEmpty ? "Swift Playground generator failure." : info
        }
    }
}
