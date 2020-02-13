//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels
import Bow
import BowEffects

public extension Kleisli where D == NefModels.Console, F == IOPartial<nef.Error> {
    func unsafeRunSync(on queue: DispatchQueue = .main) throws -> A {
        try provide(MacDummyConsole()).unsafeRunSync()
    }
    
    func unsafeRunSyncEither(on queue: DispatchQueue = .main) -> Either<nef.Error, A> {
        provide(MacDummyConsole()).unsafeRunSyncEither()
    }
    
    func unsafeRunAsync(with d: D, on queue: DispatchQueue = .main, _ callback: @escaping Callback<nef.Error, A>) {
        provide(MacDummyConsole()).unsafeRunAsync(callback)
    }
}
