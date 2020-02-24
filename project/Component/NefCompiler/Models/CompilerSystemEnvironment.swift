//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon

public struct CompilerSystemEnvironment {
    public let shell: CompilerShell
    public let fileSystem: FileSystem
    public let nefPlaygroundSystem: NefPlaygroundSystem
}
