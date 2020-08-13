//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public struct SwiftPackageProduct {
    let name: String
    let dependencies: [String]
}

public extension Array where Element == SwiftPackageProduct {
    func names() -> [String] {
        (map(\.name) + flatMap(\.dependencies)).uniques()
    }
}
