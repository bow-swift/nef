//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct PlaygroundEnvironment {
    public let progressReport: ProgressReport
    public let shell: PackageShell
    public let system: FileSystem
    
    public init(
        progressReport: ProgressReport,
        shell: PackageShell,
        system: FileSystem) {
        
        self.progressReport = progressReport
        self.shell = shell
        self.system = system
    }
}
