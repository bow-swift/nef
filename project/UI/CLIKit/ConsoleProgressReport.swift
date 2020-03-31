import NefModels
import BowEffects
import nef
import Foundation

public struct ConsoleProgressReport: ProgressReport {
    public init() {}
    
    public func notify<E: Swift.Error, A>(_ event: ProgressEvent<A>) -> IO<E, Void> {
        switch event.status {
        
        case .oneShot:
            return ConsoleIO.print(event.step.progressDescription)
            
        case .inProgress:
            return ConsoleIO.print(event.step.progressDescription, terminator: " ")
            
        case let .successful(info: info):
            return ConsoleIO.print("✓".bold.green + info, terminator: "\n")
            
        case let .failed(error, info: info):
            return ConsoleIO.print("✗".bold.red + info + error.localizedDescription, terminator: "\n")
        }
    }
}

extension ProgressReport {
    func exit<A: CustomProgressDescription, E: Swift.Error>(success step: A) -> IO<E, Void> {
        oneShot(step).map { Darwin.exit(0) }^
    }
    
    func exit<A: CustomProgressDescription, E: Swift.Error>(failure step: A) -> IO<E, Void> {
        oneShot(step).map { Darwin.exit(-1) }^
    }
}

public extension EnvIO where D == ProgressReport {
    func finish<A: CustomProgressDescription>(
        onSuccess: A,
        onFailure: @escaping (nef.Error) -> A) -> EnvIO<ProgressReport, nef.Error, Void> where F == IOPartial<nef.Error> {
        self.foldM(
            { e in
                EnvIO { progressReport in
                    progressReport.exit(failure: onFailure(e))
                }
            },
            { _ in
                EnvIO { progressReport in
                    progressReport.exit(success: onSuccess)
                }
            })
    }
}
