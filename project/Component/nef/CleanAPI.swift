//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefClean
import Bow
import BowEffects


public extension CleanAPI {
    
    static func clean(nefPlayground: URL) -> EnvIO<ProgressReport, nef.Error, Void> {
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

enum CleanCommandOutcome {
    case successful(String)
    case failed(String, error: nef.Error)
}

extension CleanCommandOutcome: CustomProgressDescription {
    var progressDescription: String {
        switch self {
        case .successful(let name):
            return  "'\(name)' clean up successfully"
        
        case let .failed(name, error: error):
            return "clean up nef Playground '\(name)' failed with error: \(error)"
        }
    }
}
