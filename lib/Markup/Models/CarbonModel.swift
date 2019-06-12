//  Copyright © 2019 The nef Authors.

import Foundation

public struct Carbon {
    public let code: String
    public let style: CarbonStyle
}

public struct CarbonStyle {
    public let size: CarbonSize
    public let background: Color
    
    public init(size: CarbonSize, background: Color) {
        self.size = size
        self.background = background
    }
    
    public struct Color: CustomStringConvertible {
        public let r: UInt8
        public let g: UInt8
        public let b: UInt8
        public let a: Double
        
        public init(r: UInt8, g: UInt8, b: UInt8, a: Double) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
        
        public var description: String {
            guard a > 0 else { return "\(r)%2C%20\(g)%2C%20\(b)%2C%20\(1)" }
            return "\(r)%2C%20\(g)%2C%20\(b)%2C%20\(a)"
        }
    }
    
    public enum CarbonSize: String {
        case x1 = "14px"
        case x2 = "18px"
        case x4 = "22px"
    }
}

public struct CarbonError: Error {
    public let filename: String
    public let snippet: String
    public let error: CarbonErrorOption
    
    public init(filename: String, snippet: String, error: CarbonErrorOption) {
        self.filename = filename
        self.snippet = snippet
        self.error = error
    }
    
    // MARK: Error options
    public enum CarbonErrorOption: CustomStringConvertible {
        case notFound
        case invalidSnapshot
        
        public var description: String {
            switch self {
            case .notFound: return "can not open carbon with selected code snippet"
            case .invalidSnapshot: return "can not take a snapshot"
            }
        }
    }
}
