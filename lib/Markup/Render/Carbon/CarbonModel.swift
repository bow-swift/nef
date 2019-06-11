//  Copyright © 2019 The nef Authors.

import Foundation

public struct Carbon {
    let code: String
    let style: CarbonStyle
}

public struct CarbonStyle {
    let size: CarbonSize
    
    public init(size: CarbonSize) {
        self.size = size
    }
    
    public enum CarbonSize: String {
        case x1 = "14px"
        case x2 = "18px"
        case x4 = "22px"
    }
}

public enum CarbonError: Error {
    case notFound
    case invalidSnapshot
}
