//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

public struct RenderingPersistence<A> {
    public let writePage: (_ page: RenderingOutput<A>, _ file: URL) -> EnvIO<FileSystem, RenderingPersistenceError, Void>
    
    public init(writePage: @escaping (_ page: RenderingOutput<A>, _ file: URL) -> EnvIO<FileSystem, RenderingPersistenceError, Void>) {
        self.writePage = writePage
    }
}
