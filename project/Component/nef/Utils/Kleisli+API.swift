//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

/// Transforms an `EnvIO<Console, nef.Error, A>` into `IO<nef.Error, A>` using a dummy console.
public extension Kleisli where D == NefModels.Console, F == IOPartial<nef.Error> {
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner, resolving the dependency of type `Console` using a dummy implementation.
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `nef.Error` that may happen during the evaluation of the side-effects.
    func unsafeRunSync(on queue: DispatchQueue = .main) throws -> A {
        try provide(MacDummyConsole()).unsafeRunSync()
    }
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner, resolving the dependency of type `Console` using a dummy implementation.
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    func unsafeRunSyncEither(on queue: DispatchQueue = .main) -> Either<nef.Error, A> {
        provide(MacDummyConsole()).unsafeRunSyncEither()
    }
    
    /// Performs the side effects that are suspended in this IO in an asynchronous manner, resolving the dependency of type `Console` using a dummy implementation.
    /// - Parameters
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation.
    func unsafeRunAsync(on queue: DispatchQueue = .main, _ callback: @escaping Callback<nef.Error, A>) {
        provide(MacDummyConsole()).unsafeRunAsync(callback)
    }
}
