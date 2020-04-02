import BowEffects

public protocol ProgressReport {
    func notify<E: Error, A: CustomProgressDescription>(_ event: ProgressEvent<A>) -> IO<E, Void>
}

public extension ProgressReport {
    func oneShot<E: Error, A: CustomProgressDescription>(_ step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .oneShot))
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
    
    func failed<E: Error, A: CustomProgressDescription>(_ step: A, _ error: E) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .failed(error)))
    }
    
    func finished<E: Error, A: CustomProgressDescription>(successfully step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .finishedSuccessfully))
    }
    
    func finished<E: Error, A: CustomProgressDescription>(withError step: A) -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .finishedWithError))
    }
}

public enum ProgressEventStatus {
    case oneShot
    case inProgress
    case successful
    case failed(Error)
    case finishedSuccessfully
    case finishedWithError
}

public protocol CustomProgressDescription {
    var progressDescription: String { get }
}

public struct ProgressEvent<A: CustomProgressDescription> {
    public let step: A
    public let status: ProgressEventStatus
    
    public init(step: A, status: ProgressEventStatus) {
        self.step = step
        self.status = status
    }
}
