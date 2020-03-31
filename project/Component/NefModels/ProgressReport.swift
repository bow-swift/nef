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
    
    func succeeded<E: Error, A: CustomProgressDescription>(_ step: A, info: String = "") -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .successful(info: info)))
    }
    
    func failed<E: Error, A: CustomProgressDescription>(_ step: A, _ error: E, info: String = "") -> IO<E, Void> {
        self.notify(
            ProgressEvent(step: step,
                          status: .failed(error, info: info)))
    }
}

public enum ProgressEventStatus {
    case oneShot
    case inProgress
    case successful(info: String)
    case failed(Error, info: String)
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
