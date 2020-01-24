//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public extension EnumeratedSequence {
    func traverse<G: Applicative, B>(_ f: @escaping (_ offset: Int, _ element: Base.Element) -> Kind<G, B>) -> Kind<G, [B]> {
        map(f).sequence()
    }
}
