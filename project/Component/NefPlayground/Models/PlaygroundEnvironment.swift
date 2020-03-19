//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct PlaygroundEnvironment {
    public let console: Console
    public let fileSystem: FileSystem
    public let nefPlaygroundSystem: NefPlaygroundSystem
    public let xcodePlaygroundSystem: XcodePlaygroundSystem
    
    public init(console: Console, fileSystem: FileSystem, nefPlaygroundSystem: NefPlaygroundSystem, xcodePlaygroundSystem: XcodePlaygroundSystem) {
        self.console = console
        self.fileSystem = fileSystem
        self.nefPlaygroundSystem = nefPlaygroundSystem
        self.xcodePlaygroundSystem = xcodePlaygroundSystem
    }
}
