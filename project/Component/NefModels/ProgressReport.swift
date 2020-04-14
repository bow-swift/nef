import Bow
import BowEffects

public protocol ProgressReport {
    func notify<E: Error, A: CustomProgressDescription>(_ event: ProgressEvent<A>) -> IO<E, Void>
}

public extension ProgressReport {
    func oneShot<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.inProgress(step).followedBy(self.succeeded(step))^
    }
    
    func inProgress<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .inProgress))
    }
    
    func succeeded<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .successful))
    }
    
    func failed<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .failed))
    }
}

public enum ProgressEventStatus {
    case inProgress
    case successful
    case failed
}

public protocol CustomProgressDescription {
    var progressDescription: String { get }
    var currentStep: UInt { get }
    var totalSteps: UInt { get }
}

public extension CustomProgressDescription {
    var currentStep: UInt { 1 }
    var totalSteps: UInt { 1 }
}

public struct ProgressEvent<A: CustomProgressDescription> {
    public let step: A
    public let status: ProgressEventStatus
    
    public init(step: A, status: ProgressEventStatus) {
        self.step = step
        self.status = status
    }
}
