//  Copyright © 2019 The nef Authors.

import BowOptics

extension PLens where S == T {
    func merge<AA, BB>(_ other: PLens<S, S, AA, BB>) -> PLens<S, S, (A, AA), (B, BB)> {
        PLens<S, T, (A, AA), (B, BB)>(get: { s in (self.get(s), other.get(s)) },
                                      set: { s, b in other.set(self.set(s, b.0), b.1) })
    }
}
