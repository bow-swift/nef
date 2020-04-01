//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
@_exported import NefModels
import NefClean
import Bow
import BowEffects

/// Describes the API for `Clean`
public protocol CleanAPI {
    /// Cleans a nef Playground.
    ///
    /// - Parameters:
    ///   - nefPlayground: Folder where to search for Xcode Playgrounds - it must be a nef Playground structure.
    ///   - Returns: An `EnvIO` to perform IO operations that produce errors of type `nef.Error`, having access to an immutable environment of type `ProgressReport`.
    static func clean(nefPlayground: URL) -> EnvIO<ProgressReport, nef.Error, Void>
}

/// Instance of the Clean API
public enum Clean: CleanAPI {
    public static func clean(nefPlayground: URL) -> EnvIO<ProgressReport, nef.Error, Void> {
        NefClean.Clean()
            .nefPlayground(.init(project: nefPlayground))
            .contramap { progressReport in
                CleanEnvironment(
                    progressReport: progressReport,
                    fileSystem: MacFileSystem(),
                    shell: MacNefPlaygroundSystem()) }
            .mapError { e in nef.Error.compiler(info: "clean: \(e)") }
        .reportOutcome(
            success: "'\(nefPlayground.lastPathComponent)' clean up successfully",
            failure: "clean up nef Playground '\(nefPlayground.lastPathComponent)'")
    }
}
