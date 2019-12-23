//  Copyright © 2019 The nef Authors.

import NefModels

public typealias Shell = (out: Console, run: MarkdownShell)

public struct MarkdownEnvironment {
    public let shell: Shell
    public let system: MarkdownSystem
    
    public init(console: Console, shell: MarkdownShell, system: MarkdownSystem) {
        self.shell = (out: console, run: shell)
        self.system = system
    }
}
