//  Copyright © 2019 The nef Authors.

import Foundation

public struct Carbon {
    public let code: String
    public let style: CarbonStyle
}

public struct CarbonStyle {
    public let background: Color
    public let size: Size
    public let theme: Theme
    public let fontType: Font
    public let lineNumbers: Bool
    
    public init(background: Color, size: Size, theme: Theme, fontType: Font, lineNumbers: Bool) {
        self.background = background
        self.size = .x4
        self.theme = theme
        self.fontType = fontType
        self.lineNumbers = lineNumbers
    }
    
    public enum Size: CGFloat {
        case x1 = 1
        case x2 = 2
        case x3 = 3
        case x4 = 4
        case x5 = 5
    }
    
    public enum Theme: String {
        case dracula
    }
    
    public enum Font: String {
        case hack = "Hack"
        case firaCode = "Fira Code"
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
            guard a > 0 else { return "rgba(\(r),\(g),\(b),\(1))" }
            return "rgba(\(r),\(g),\(b),\(a))"
        }
        
        // MARK: - defined
        public static let bow = Color(r: 213, g: 64, b: 72, a: 1)
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
