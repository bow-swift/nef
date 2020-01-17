//  Copyright © 2019 The nef Authors.

import NefModels
import NefCommon

public struct MarkdownEnvironment {
    public let console: Console
    public let playgroundSystem: PlaygroundSystem
    public let fileSystem: MarkdownSystem
    
    public init(console: Console, playgroundSystem: PlaygroundSystem, fileSystem: MarkdownSystem) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.fileSystem = fileSystem
    }
}
