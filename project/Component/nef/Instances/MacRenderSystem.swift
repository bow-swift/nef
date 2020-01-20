//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import Bow
import BowEffects

extension RenderSystem where A == String {
    init() { self.init { page, file in
        EnvIO { fileSystem in
            let folder = file.deletingLastPathComponent()
            
            return binding(
                |<-fileSystem.createDirectory(atPath: folder.path).mapLeft { _ in .structure(folder: folder) },
                |<-fileSystem.write(content: page.output.all().joined(), toFile: file.path).mapLeft { _ in .persist(item: file) },
            yield: ())
        }
    }}
}
