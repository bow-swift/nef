//  Copyright © 2019 The nef Authors.

import Foundation
import BowEffects

public struct Step {
    public let total: UInt
    public let partial: UInt
    public let estimatedDuration: DispatchTimeInterval
    
    public init(total: UInt, partial: UInt, duration: DispatchTimeInterval) {
        self.total = total
        self.partial = partial
        self.estimatedDuration = duration
    }
}

extension Step {
    public static var empty: Step { .init(total: 0, partial: 0, duration: .never) }
    
    public func increment(_ partial: UInt) -> Step {
        .init(total: total, partial: self.partial + partial, duration: estimatedDuration)
    }
}

public protocol Console {
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void>
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void>
    func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void>
    func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void>
}

public extension Console {
    func print<E: Swift.Error>(information: String) -> IO<E, Void> {
        printStep(step: Step.empty, information: information)
    }
    
    func print<E: Swift.Error>(information: [String]) -> IO<E, Void> {
        printSubstep(step: Step.empty, information: information)
    }
}
