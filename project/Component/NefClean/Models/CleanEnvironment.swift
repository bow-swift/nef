//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels

public struct CleanEnvironment {
    public let console: Console
    public let shell: PlaygroundShell
    
    public init(console: Console, shell: PlaygroundShell) {
        self.console = console
        self.shell = shell
    }
}

