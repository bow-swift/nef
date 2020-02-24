//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct CleanEnvironment {
    public let console: Console
    public let fileSystem: FileSystem
    public let shell: PlaygroundShell
    
    public init(console: Console, fileSystem: FileSystem, shell: PlaygroundShell) {
        self.console = console
        self.fileSystem = fileSystem
        self.shell = shell
    }
}
