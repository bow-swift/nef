//  Copyright © 2020 The nef Authors.

import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        index < count ? self[index] : nil
    }
}
