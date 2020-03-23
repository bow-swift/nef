//  Copyright © 2019 The nef Authors.

import Foundation
import BowEffects

/// Describes the information to track the progress of an operation.
public struct Step {
    /// Total of operations
    public let total: UInt
    
    /// Current operation. Values between [0, total]
    public let partial: UInt
    
    /// Estimated duration for current operation.
    public let estimatedDuration: DispatchTimeInterval
    
    /// Initializes a `Step`
    ///
    /// - Parameters:
    ///   - total: Total of operations.
    ///   - partial: The current operation. Values between [0, total]
    ///   - duration: Estimated duration for current operation.
    public init(total: UInt, partial: UInt, duration: DispatchTimeInterval) {
        self.total = total
        self.partial = partial
        self.estimatedDuration = duration
    }
}

extension Step {
    /// Defined dummy `Step`
    public static var empty: Step { .init(total: 0, partial: 0, duration: .never) }
    
    /// Advance the step a number of increments.
    /// - Parameter partial: Number of increments for the step.
    /// - Returns: A `Step` with the current operation advanced.
    public func increment(_ partial: UInt) -> Step {
        .init(total: total, partial: self.partial + partial, duration: estimatedDuration)
    }
}

/// Describes a `Console` to represent progress information.
public protocol Console {
    
    /// Detailed information about the progress of current step.
    /// - Parameters:
    ///   - step: Current `Step`
    ///   - information: Detailed information.
    /// - Returns: An `IO` that represent the information for the step.
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void>
    
    /// Detailed information about the progress of a subtask in current step.
    /// - Parameters:
    ///   - step: Current `Step`
    ///   - information: Detailed information.
    /// - Returns: An `IO` that represent the information for the substep.
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void>
    
    /// Describes how the step has been terminated.
    /// - Parameter success: Output status.
    /// - Returns: An `IO` that represent the output status.
    func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void>
    
    /// Describes how the step has been terminated with detailed information.
    /// - Parameters:
    ///   - information: Detailed information.
    ///   - success: Output status.
    /// - Returns: An `IO` that represent the output status.
    func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void>
}

public extension Console {
    
    /// Detailed information about the progress of current step.
    /// - Parameter information: Detailed information.
    /// - Returns: An `IO` that represent the information for the step.
    func print<E: Swift.Error>(information: String) -> IO<E, Void> {
        printStep(step: Step.empty, information: information)
    }
    
    /// Detailed information about the progress of a subtask in current step.
    /// - Parameter information: Detailed information.
    /// - Returns: An `IO` that represent the information for the substep.
    func print<E: Swift.Error>(information: [String]) -> IO<E, Void> {
        printSubstep(step: Step.empty, information: information)
    }
}
