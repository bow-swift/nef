//  Copyright © 2019 The nef Authors.

import Foundation

/// Models a `nef` error.
public enum Error: Swift.Error {
    /// Describes a `Compiler` error with detailed information.
    case compiler(info: String)
    
    /// Describes a `Markdown` error with detailed information.
    case markdown(info: String)
    
    /// Describes a `Jekyll` error with detailed information.
    case jekyll(info: String)
    
    /// Describes a `Carbon` error with detailed information.
    case carbon(info: String)
    
    /// Describes a `Carbon` error with detailed information about the snapshot failure.
    case invalidSnapshot(info: String)
    
    /// Describes a `Playground` error with detailed information.
    case playground(info: String)
    
    /// Describes a `Swift Playground` error with detailed information.
    case swiftPlaygrond(info: String)
}

extension Error: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .compiler(let info):
            return "Compiler failure. \(info.firstCapitalized)"
        case .markdown(let info):
            return "Markdown failure. \(info.firstCapitalized)"
        case .jekyll(let info):
            return "Jekyll failure. \(info.firstCapitalized)"
        case .carbon(let info):
            return "Carbon failure. \(info.firstCapitalized)"
        case .invalidSnapshot(let info):
            return "Invalid snapshot. \(info.firstCapitalized)"
        case .playground(let info):
            return "Playground generator failure. \(info.firstCapitalized)"
        case .swiftPlaygrond(let info):
            return "Swift Playground generator failure. \(info.firstCapitalized)"
        }
    }
}
