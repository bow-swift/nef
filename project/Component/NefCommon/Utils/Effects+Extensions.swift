//  Copyright © 2020 The nef Authors.

import Bow
import BowEffects
import NefModels

public extension IO {
    func foldMTap<B>(_ f: @escaping (E) -> IO<E, B>,
                     _ g: @escaping (A) -> IO<E, B>) -> IO<E, A> {
        flatTap(g).handleErrorWith { e in
            f(e).followedBy(.raiseError(e))
        }^
    }
    
    func step<B: CustomProgressDescription>(
        _ step: B,
        reportCompleted progressReport: ProgressReport
    ) -> IO<E, A> {
        
        self.foldMTap({ e in progressReport.failed(step) },
                      { _ in progressReport.succeeded(step) })
    }
}

public extension EnvIO where D: HasProgressReport {
    func step<E: Error, B: CustomProgressDescription>(_ step: B) -> EnvIO<D, E, A> where F == IOPartial<E> {
        EnvIO { env in
            self.provide(env).step(step, reportCompleted: env.progressReport)
        }
    }
}
