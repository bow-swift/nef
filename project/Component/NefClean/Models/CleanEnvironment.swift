//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct CleanEnvironment {
    public let progressReport: ProgressReport
    public let fileSystem: FileSystem
    public let shell: NefPlaygroundSystem
    
    public init(progressReport: ProgressReport, fileSystem: FileSystem, shell: NefPlaygroundSystem) {
        self.progressReport = progressReport
        self.fileSystem = fileSystem
        self.shell = shell
    }
}
