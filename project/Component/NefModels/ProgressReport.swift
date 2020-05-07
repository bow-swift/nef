import Bow
import BowEffects

/// Notify about the progress of an event.
public protocol ProgressReport {
    /// Notify about the status of an event.
    /// - Parameter event: progress description.
    /// - Returns: An `IO` that represent the information for the event.
    func notify<E: Error, A: CustomProgressDescription>(_ event: ProgressEvent<A>) -> IO<E, Void>
}

public extension ProgressReport {
    /// Describes a succeeded event.
    /// - Parameter step: step description.
    /// - Returns: An `IO` that represent the information for the succeeded event.
    func oneShot<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.inProgress(step).followedBy(self.succeeded(step))^
    }
    
    /// Describes an event has just been initiated.
    /// - Parameter step: step description.
    /// - Returns: An `IO` that represent the information for the initiated event.
    func inProgress<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .inProgress))
    }
    
    /// Describes the progress of an event finished with status `succeeded`.
    /// - Parameter step: step description.
    /// - Returns: An `IO` that represent the information for the succeeded event.
    func succeeded<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .successful))
    }
    
    /// Describes the progress of an event finished with status `failed`.
    /// - Parameter step: step description.
    /// - Returns: An `IO` that represent the information for the failed event.
    func failed<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .failed))
    }
}

/// Models the `progress status` for an event.
public enum ProgressEventStatus {
    /// Event is running.
    case inProgress
    /// Event has finished successfully.
    case successful
    /// Event has failed.
    case failed
}

/// Models the `step` description for an event.
public protocol CustomProgressDescription {
    /// Detailed information about progress in current step.
    var progressDescription: String { get }
    /// Describes which is the current step for an event.
    var currentStep: UInt { get }
    /// Describes the number of steps for an event.
    var totalSteps: UInt { get }
}

public extension CustomProgressDescription {
    var currentStep: UInt { 1 }
    var totalSteps: UInt { 1 }
}

/// Models an `event`.
public struct ProgressEvent<A: CustomProgressDescription> {
    /// Describes the current step.
    public let step: A
    /// Describes the progress status.
    public let status: ProgressEventStatus
    
    /// Initializes a `Platform`
    ///
    /// - Parameters:
    ///   - step: current step.
    ///   - status: progress status.
    public init(step: A, status: ProgressEventStatus) {
        self.step = step
        self.status = status
    }
}
