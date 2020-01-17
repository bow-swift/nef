//  Copyright © 2019 The nef Authors.

import NefModels
import NefCommon

public struct RenderEnvironment {
    public let console: Console
    public let playgroundSystem: PlaygroundSystem
    public let fileSystem: RenderSystem
    
    public init(console: Console, playgroundSystem: PlaygroundSystem, fileSystem: RenderSystem) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.fileSystem = fileSystem
    }
}
