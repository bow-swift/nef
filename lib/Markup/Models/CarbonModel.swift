//  Copyright © 2019 The nef Authors.

import Foundation

public struct Carbon {
    public let code: String
    public let style: CarbonStyle
}

public struct CarbonStyle {
    public let size: CarbonSize
    
    public init(size: CarbonSize) {
        self.size = size
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
