//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public struct CompilerSystemEnvironment {
    public let fileSystem: FileSystem
    public let shell: CompilerShell
    public let playgroundShell: PlaygroundShell
}
