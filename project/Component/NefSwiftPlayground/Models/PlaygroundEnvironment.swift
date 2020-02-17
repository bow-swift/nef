//  Copyright © 2019 The nef Authors.

import Foundation
import NefCommon
import NefModels

public typealias Shell = (out: Console, run: PackageShell)

public struct PlaygroundEnvironment {
    public let shell: Shell
    public let system: FileSystem
    
    public init(console: Console, shell: PackageShell, system: FileSystem) {
        self.shell = (out: console, run: shell)
        self.system = system
    }
}
