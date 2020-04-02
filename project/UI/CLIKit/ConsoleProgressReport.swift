import NefModels
import BowEffects
import nef
import Foundation

public struct ConsoleProgressReport: ProgressReport {
    public init() {}
    
    public func notify<E: Swift.Error, A>(_ event: ProgressEvent<A>) -> IO<E, Void> {
        switch event.status {
        
        case .oneShot:
            return ConsoleIO.print(event.step.progressDescription + " ✓".bold.green)
            
        case .inProgress:
            return ConsoleIO.print(event.step.progressDescription, terminator: " ")
            
        case .successful:
            return ConsoleIO.print("✓ ".bold.green)
            
        case let .failed(error):
            return ConsoleIO.print("✗ ".bold.red + " \(error)")
        
        case .finishedSuccessfully:
            return ConsoleIO.print("🙌 " + event.step.progressDescription)
            
        case .finishedWithError:
            return ConsoleIO.print("☠️ " + event.step.progressDescription)
        }
    }
}


public extension EnvIO where F == IOPartial<nef.Error>, D == ProgressReport {
    func finish() -> EnvIO<ProgressReport, nef.Error, Void>  {
        self.foldM(
            { e in
                EnvIO.invoke { _ in Darwin.exit(-1) }
            },
            { _ in
                EnvIO.invoke { _ in Darwin.exit(0) }
            })
    }
}
