//  Copyright © 2019 The nef Authors.

import Foundation

public extension Array {
    func appending<S: Sequence>(contentsOf newElements: S) -> [Element] where Element == S.Element {
        newElements.reduce(self) { (acc: [Element], elem: Element) in acc + [elem] }
    }
}

public extension ArraySlice {
    func dropLast(while f: (Iterator.Element) -> Bool, include: Bool = true) -> ArraySlice {
        guard let index = lastIndex(where: { !f($0) }) else { return [] }
        let lastIndex = count - (index + (include ? 1 : 0))
        return lastIndex < count ? dropLast(lastIndex) : self
    }
}
