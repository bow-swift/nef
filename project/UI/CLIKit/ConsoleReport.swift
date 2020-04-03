import NefModels
import BowEffects
import nef
import Foundation

public struct ConsoleReport {
    public init() {}
}

extension ConsoleReport: ProgressReport {
    public func notify<E: Swift.Error, A>(_ event: ProgressEvent<A>) -> IO<E, Void> {
        switch event.status {
            
        case .inProgress:
            return ConsoleIO.print(event.step.progressDescription, terminator: " ")
            
        case .successful:
            return ConsoleIO.print("✓ ".bold.green)
            
        case .failed:
            return ConsoleIO.print("✗ ".bold.red)
        }
    }
}

extension ConsoleReport: OutcomeReport {
    public func notify<E: Swift.Error>(_ outcome: String) -> IO<E, Void> {
        ConsoleIO.print(outcome)
    }
}
