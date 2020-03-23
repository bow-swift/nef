//  Copyright © 2019 The nef Authors.

import Foundation

/// Models a `nef` error.
public enum Error: Swift.Error {
    /// Describes a `Compiler` error given detailed information.
    case compiler(info: String = "")
    
    /// Describes a `Markdown` error given detailed information.
    case markdown(info: String = "")
    
    /// Describes a `Jekyll` error given detailed information.
    case jekyll(info: String = "")
    
    /// Describes a `Carbon` error given detailed information.
    case carbon(info: String = "")
    
    /// Describes a `Carbon` error given detailed information about the snapshot failure.
    case invalidSnapshot(info: String = "")
    
    /// Describes a `Playground` error given detailed information.
    case playground(info: String = "")
    
    /// Describes a `Swift Playground` error given detailed information.
    case swiftPlaygrond(info: String = "")
}

extension Error: CustomStringConvertible {
    
    /// A textual representation of `nef.Error`
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
