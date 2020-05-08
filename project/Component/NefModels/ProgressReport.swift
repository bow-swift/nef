import Bow
import BowEffects

/// Notifies the progress of an event.
public protocol ProgressReport {
    /// Notifies the status of an event.
    /// - Parameter event: Progress description.
    /// - Returns: An `IO` describing the progress report.
    func notify<E: Error, A: CustomProgressDescription>(_ event: ProgressEvent<A>) -> IO<E, Void>
}

public extension ProgressReport {
    /// Reports an event that completes successfully and instantly.
    /// - Parameter step: Step description.
    /// - Returns: An `IO` describing the progress report.
    func oneShot<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.inProgress(step).followedBy(self.succeeded(step))^
    }
    
    /// Reports an ongoing event.
    /// - Parameter step: Step description.
    /// - Returns: An `IO` describing the progress report.
    func inProgress<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .inProgress))
    }
    
    /// Reports the successful completion of an event.
    /// - Parameter step: Step description.
    /// - Returns: An `IO` describing the progress report.
    func succeeded<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .successful))
    }
    
    /// Reports the failed completion of an event.
    /// - Parameter step: Step description.
    /// - Returns: An `IO` describing the progress report.
    func failed<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .failed))
    }
}

/// Models the progress status for an event.
public enum ProgressEventStatus {
    /// Event is running.
    case inProgress
    /// Event has finished successfully.
    case successful
    /// Event has failed.
    case failed
}

/// Describes the metadata associated with a progress event.
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

/// Models an event that can be reported.
public struct ProgressEvent<A: CustomProgressDescription> {
    /// Describes the current step.
    public let step: A
    /// Describes the progress status.
    public let status: ProgressEventStatus
    
    /// Initializes a `ProgressEvent`.
    ///
    /// - Parameters:
    ///   - step: Current step.
    ///   - status: Progress status.
    public init(step: A, status: ProgressEventStatus) {
        self.step = step
        self.status = status
    }
}
