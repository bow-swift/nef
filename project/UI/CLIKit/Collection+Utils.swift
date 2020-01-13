//  Copyright © 2019 The nef Authors.

import Foundation

extension Collection where Element: Equatable & Hashable {
    func containsAll(_ array: [Element]) -> Bool {
        array.contains(where: { element in self.contains(element) })
    }
    
    func containsAny(_ array: [Element]) -> Bool {
        array.first { element in self.contains(element) } != nil
    }
}
