//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public extension IO {
    func env<D>() -> EnvIO<D, E, A> {
        EnvIO { _ in self }
    }
}

