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
        .foldM(
            { e in
                EnvIO { progressReport in
                    progressReport.finished(withError:
                        CleanCommandOutcome.failed(
                            nefPlayground.lastPathComponent,
                            error: e))
                }
            },
            {
                EnvIO { progressReport in
                    progressReport.finished(successfully: CleanCommandOutcome.successful(nefPlayground.lastPathComponent))
                }
            })
    }
}

public enum CleanCommandOutcome {
    case successful(String)
    case failed(String, error: nef.Error)
}

extension CleanCommandOutcome: CustomProgressDescription {
    public var progressDescription: String {
        switch self {
        case .successful(let name):
            return  "'\(name)' clean up successfully"
        
        case let .failed(name, error: error):
            return "clean up nef Playground '\(name)' failed with error: \(error)"
        }
    }
}
