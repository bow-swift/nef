//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

import Bow
import BowEffects


public struct PlaygroundBook {
    private let resolvePath: PlaygroundBookResolvePath
    
    init(name: String, path: String) {
        self.resolvePath = PlaygroundBookResolvePath(name: name, path: path)
    }
    
    func build(modules: [Module]) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        fatalError()
    }
}
