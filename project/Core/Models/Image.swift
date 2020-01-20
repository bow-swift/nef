//  Copyright © 2020 The nef Authors.

import Foundation

public struct Image {
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public static var empty: Image { Image(data: .init(capacity: 0)) }
    public var isEmpty: Bool { data.count == 0 }
}
