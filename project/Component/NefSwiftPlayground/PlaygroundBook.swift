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
        let generalManifiest = PlaygroundBookTemplate.Manifiest.general(chapterName: resolvePath.chapterPath.filename.removeExtension, imageName: resolvePath.imageReferenceName)
        let chapterManifiest = PlaygroundBookTemplate.Manifiest.chapter(pageName: resolvePath.pageName)
        
        return binding(
            |<-self.writeManifest(generalManifiest, toFolder: self.resolvePath.contentsPath),
            |<-self.writeManifest(chapterManifiest, toFolder: self.resolvePath.chapterPath),
        yield: ())^
    }
    
    // MARK: steps
    
    
    // MARK: steps <helpers>
    private func writeManifest(_ manifest: String, toFolder folderPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { storage in
            let createDirectoryIO = storage.createDirectory(atPath: folderPath)
            let writeManifiestIO = storage.write(content: manifest, toFile: "\(folderPath)/Manifest.plist")
            
            return createDirectoryIO.followedBy(writeManifiestIO)^.mapLeft { _ in .manifest(path: folderPath) }
        }
    }
}
