import Bow
import BowEffects

public extension Kleisli where D == ProgressReport, F == IOPartial<nef.Error> {
    
    func reportOutcome(success: String, failure: String) -> EnvIO<ProgressReport, nef.Error, Void> {
        self.foldM(
            { e in
                EnvIO { progressReport in
                    progressReport.finished(withError:
                        CommandOutcome.failed(failure, error: e))
                }
        },
            { _ in
                EnvIO { progressReport in
                    progressReport.finished(successfully: CommandOutcome.successful(success))
                }
        })
    }
}
