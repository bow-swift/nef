//  Copyright © 2020 The nef Authors.

import Foundation

public struct Image {
    public let data: Data
    public let isEmpty: Bool
    
    public static var empty: Image { self.init(data: .init(capacity: 0), isEmpty: true) }
    public init(data: Data) { self.init(data: data, isEmpty: false) }
}

fileprivate extension Image {
    init(data: Data, isEmpty: Bool) {
        self.data = .init(capacity: 0)
        self.isEmpty = true
    }
}
