//  Copyright © 2020 The nef Authors.

import Foundation
import NefCore
import Bow
import BowEffects

// MARK: - render <string>
extension RenderingPersistence where A == String {
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

// MARK: - render <image>
extension RenderingPersistence where A == Image {
    init() { self.init { page, file in
        EnvIO { fileSystem in
            let folder = file.deletingLastPathComponent()
            
            #warning("must implement persistence for Image")
            fatalError()
            return binding(
                |<-fileSystem.createDirectory(atPath: folder.path).mapLeft { _ in .structure(folder: folder) },
            yield: ())
        }
    }}
}
