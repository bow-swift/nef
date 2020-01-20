//  Copyright © 2020 The nef Authors.

import Foundation
import Bow

public extension NEA {
    func traverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, NEA<B>> {
        return ForNonEmptyArray.traverse(self, f).map { $0^ }
    }
}
