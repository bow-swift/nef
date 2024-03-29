import Bow
import BowEffects
import nef
import Foundation

public extension Kleisli where D: OutcomeReport, F == IOPartial<nef.Error> {
    
    func reportOutcome(
        success: @escaping (A) -> String,
        failure: @escaping (nef.Error) -> String
    ) -> EnvIO<D, nef.Error, Void> {
        self.foldM(
            { e in
                EnvIO { outcomeReport in
                    outcomeReport.failure(failure(e), error: e)
                }
            },
            { a in
                EnvIO { outcomeReport in
                    outcomeReport.success(success(a))
                }
            })
    }
}

public extension Kleisli where D == ProgressReport {
    func outcomeScope<T: ProgressReport & OutcomeReport>() -> Kleisli<F, T, A> {
        self.contramap(id)
    }
}

public extension Kleisli {
    func finish<E>() -> EnvIO<D, E, Void> where F == IOPartial<E> {
        self.foldM(
            { _ in
                EnvIO.invoke { _ in Darwin.exit(-1) }
            },
            { _ in
                EnvIO.invoke { _ in Darwin.exit(0) }
            })
    }
}
