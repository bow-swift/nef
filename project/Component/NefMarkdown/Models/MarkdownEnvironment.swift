//  Copyright © 2019 The nef Authors.

import NefModels

public typealias Shell = (out: Console, run: MarkdownShell)

public struct MarkdownFullEnvironment {
    public let shell: Shell
    public let system: MarkdownSystem
    
    public init(console: Console, shell: MarkdownShell, system: MarkdownSystem) {
        self.shell = (out: console, run: shell)
        self.system = system
    }
}

public struct MarkdownEnvironment {
    public let console: Console
    public let system: MarkdownSystem
    
    public init(console: Console, system: MarkdownSystem) {
        self.console = console
        self.system = system
    }
}
