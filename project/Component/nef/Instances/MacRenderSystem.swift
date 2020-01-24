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
        let folder = file.deletingLastPathComponent()
        let filename = file.lastPathComponent.removeExtension
        let fileSystem = EnvIO<FileSystem, RenderingPersistenceError, FileSystem>.var()
        let images = EnvIO<FileSystem, RenderingPersistenceError, [Data]>.var()
        
        return binding(
            fileSystem <- ask(),
                       |<-fileSystem.get.createDirectory(atPath: folder.path).mapError { _ in .structure(folder: folder) },
                images <- Self.data(images: page.output),
                       |<-Self.persist(images: images.get, folder: folder, filename: filename),
        yield: ())^
    }}
    
    private static func data(images: NEA<Image>) -> EnvIO<FileSystem, RenderingPersistenceError, [Data]> {
        EnvIO.pure(images.all().compactMap { image in
            switch image {
            case let .data(data): return data
            default: return nil
            }
        })^
    }
    
    private static func persist(images: [Data], folder: URL, filename: String) -> EnvIO<FileSystem, RenderingPersistenceError, ()> {
        let isMultiFile = images.count > 1
        
        return images.enumerated().traverse { index, image in
            let sufix = isMultiFile ? "-\(index)" : ""
            let file = folder.appendingPathComponent("\(filename)\(sufix).png")
            
            return EnvIO { fileSystem in
                fileSystem.write(content: image, toFile: file.path).mapLeft { _ in .persist(item: file) }
            }
        }.map { (a: [()]) in () }^
    }
}
