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
        let generalManifest = PlaygroundBookTemplate.Manifest.general(chapterName: resolvePath.chapterPath.filename.removeExtension, imageName: resolvePath.imageReferenceName)
        let chapterManifest = PlaygroundBookTemplate.Manifest.chapter(pageName: resolvePath.pageName)
        
        return binding(
            |<-self.writeManifest(generalManifest, toFolder: self.resolvePath.contentsPath),
            |<-self.writeManifest(chapterManifest, toFolder: self.resolvePath.chapterPath),
            |<-self.createPage(inPath: self.resolvePath.pagePath),
            |<-self.createPage(inPath: self.resolvePath.templatePagePath),
            |<-self.addResource(base64: AssetsBase64.imageReference, name: self.resolvePath.imageReferenceName, toPath: self.resolvePath.resourcesPath),
            |<-self.addModules(modules, toPath: self.resolvePath.modulesPath),
        yield: ())^
    }
    
    // MARK: steps <helpers>
    private func writeManifest(_ manifest: String, toFolder folderPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { storage in
            let createDirectoryIO = storage.createDirectory(atPath: folderPath)
            let writeManifiestIO = storage.write(content: manifest, toFile: "\(folderPath)/Manifest.plist")
            
            return createDirectoryIO.followedBy(writeManifiestIO)^.mapLeft { _ in .manifest(path: folderPath) }
        }
    }
    
    private func createPage(inPath pagePath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { storage in
            let pageHeader = PlaygroundBookTemplate.Code.header
            let manifest   = PlaygroundBookTemplate.Manifest.page(name: pagePath.filename.removeExtension)
            
            let createDirectoryIO = storage.createDirectory(atPath: pagePath)
            let writePageIO = storage.write(content: pageHeader, toFile: "\(pagePath)/main.swift")
            let writeManifiestIO = storage.write(content: manifest, toFile: "\(pagePath)/Manifest.plist")
            
            return createDirectoryIO.followedBy(writePageIO).followedBy(writeManifiestIO)^.mapLeft { _ in .page(path: pagePath) }
        }
    }
    
    private func addResource(base64: String, name resourceName: String, toPath resourcesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { storage in
            guard let data = Data(base64Encoded: base64) else { return IO.raiseError(.resource(name: resourceName))^ }
            let createDirectoryIO = storage.createDirectory(atPath: resourcesPath)
            let writeResourceIO = storage.write(content: data, toFile: "\(resourcesPath)/\(resourceName)")
            
            return createDirectoryIO.followedBy(writeResourceIO)^.mapLeft { _ in .resource(name: resourceName) }
        }
    }
    
    private func addModules(_ modules: [Module], toPath modulesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        
        func copy(module: Module, to modulesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
            let dest = IOPartial<PlaygroundBookError>.var(String.self)
            return EnvIO { storage in
                return binding(
                    dest <- createModuleDirectory(atPath: modulesPath, andName: module.name).provide(storage),
                         |<-storage.copy(itemPaths: module.sources, to: dest.get).mapLeft { _ in .sources(module: module.name) },
                yield: ())^
            }
        }
        
        func createModuleDirectory(atPath path: String, andName name: String) -> EnvIO<FileSystem, PlaygroundBookError, String> {
            EnvIO { storage in
                let modulePath = "\(path)/\(name).playgroundmodule"
                let sourcesPath = "\(modulePath)/Sources"
                
                return storage.createDirectory(atPath: sourcesPath)^
                              .mapLeft { _ in .invalidModule(name: name) }
                              .map { _ in sourcesPath }
            }
        }
        
        
        return EnvIO { storage in
            modules.k().foldLeft(IO<PlaygroundBookError, ()>.lazy()) { partial, module in
                partial.forEffect(copy(module: module, to: modulesPath).invoke(storage))
            }^
        }
    }
}
