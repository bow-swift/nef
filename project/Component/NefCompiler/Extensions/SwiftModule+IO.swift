//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import Bow
import BowEffects

extension Array where Element == String {
    func swiftModules<E: Error>() -> EnvIO<FileSystem, E, [SwiftModule]> {
        parTraverse { module in module.swiftModule() }
            .map { modules in modules.compactMap(\.orNil) }^
    }
}

private extension String {
    func swiftModule<E: Error>() -> EnvIO<FileSystem, E, Option<SwiftModule>> {
        EnvIO { fileSystem in
            guard let swiftModule = SwiftModule(name: self.filename.removeExtension, at: self.parentPath),
                  fileSystem.exist(itemPath: swiftModule.module.path),
                  fileSystem.exist(itemPath: swiftModule.binary.path) else { return IO.pure(.none())^ }
            
            return IO.pure(.some(swiftModule))^
        }^
    }
}
