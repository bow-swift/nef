//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

@discardableResult
public func version(console: CLIKit.Console) -> Either<CLIKit.Console.Error, Void> {
    nef.Version.info()
               .mapError { _ in .render() }^
               .flatMap { version in console.print(message: "Build's version number: \(version)") }^
               .unsafeRunSyncEither()
}
