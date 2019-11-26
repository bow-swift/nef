//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

public struct PlaygroundEnvironment {
    public let console: Console
    public let storage: FileSystem
    
    public init(console: Console, storage: FileSystem) {
        self.console = console
        self.storage = storage
    }
}
