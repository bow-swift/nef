//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct PlaygroundEnvironment {
    public let progressReport: ProgressReport
    public let fileSystem: FileSystem
    public let nefPlaygroundSystem: NefPlaygroundSystem
    public let xcodePlaygroundSystem: XcodePlaygroundSystem
    
    public init(
        progressReport: ProgressReport,
        fileSystem: FileSystem,
        nefPlaygroundSystem: NefPlaygroundSystem,
        xcodePlaygroundSystem: XcodePlaygroundSystem) {
        
        self.progressReport = progressReport
        self.fileSystem = fileSystem
        self.nefPlaygroundSystem = nefPlaygroundSystem
        self.xcodePlaygroundSystem = xcodePlaygroundSystem
    }
}
