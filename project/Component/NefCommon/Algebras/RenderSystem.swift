//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RenderSystem<A> {
    public let writePage: (_ page: RenderingOutput<A>.PageOutput, _ file: URL) -> EnvIO<FileSystem, RenderSystemError, Void>
}
