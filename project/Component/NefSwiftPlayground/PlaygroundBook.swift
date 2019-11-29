//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels
import NefCommon

import Bow
import BowEffects

public struct PlaygroundBook {
    private let resolutionPath: PlaygroundBookResolutionPath
    
    init(name: String, path: String) {
        self.resolutionPath = PlaygroundBookResolutionPath(name: name, path: path)
    }
    
    func build(modules: [Module]) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        let generalManifest = PlaygroundBookTemplate.Manifest.general(chapterName: resolutionPath.chapterPath.filename.removeExtension, imageName: resolutionPath.imageReferenceName)
        let chapterManifest = PlaygroundBookTemplate.Manifest.chapter(pageName: resolutionPath.pageName)
        
        return binding(
            |<-self.writeManifest(generalManifest, toFolder: self.resolutionPath.contentsPath),
            |<-self.writeManifest(chapterManifest, toFolder: self.resolutionPath.chapterPath),
            |<-self.createPage(inPath: self.resolutionPath.pagePath),
            |<-self.createPage(inPath: self.resolutionPath.templatePagePath),
            |<-self.addResource(base64: AssetsBase64.imageReference, name: self.resolutionPath.imageReferenceName, toPath: self.resolutionPath.resourcesPath),
            |<-self.addModules(modules, toPath: self.resolutionPath.modulesPath),
        yield: ())^
    }
    
    // MARK: steps <helpers>
    private func writeManifest(_ manifest: String, toFolder folderPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { system in
            let createDirectoryIO = system.createDirectory(atPath: folderPath)
            let writeManifiestIO = system.write(content: manifest, toFile: "\(folderPath)/Manifest.plist")
            
            return createDirectoryIO.followedBy(writeManifiestIO)^.mapLeft { _ in .manifest(path: folderPath) }
        }
    }
    
    private func createPage(inPath pagePath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { system in
            let pageHeader = PlaygroundBookTemplate.Code.header
            let manifest   = PlaygroundBookTemplate.Manifest.page(name: pagePath.filename.removeExtension)
            
            let createDirectoryIO = system.createDirectory(atPath: pagePath)
            let writePageIO = system.write(content: pageHeader, toFile: "\(pagePath)/main.swift")
            let writeManifiestIO = system.write(content: manifest, toFile: "\(pagePath)/Manifest.plist")
            
            return createDirectoryIO.followedBy(writePageIO).followedBy(writeManifiestIO)^.mapLeft { _ in .page(path: pagePath) }
        }
    }
    
    private func addResource(base64: String, name resourceName: String, toPath resourcesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        EnvIO { system in
            guard let data = Data(base64Encoded: base64) else { return IO.raiseError(.resource(name: resourceName))^ }
            let createDirectoryIO = system.createDirectory(atPath: resourcesPath)
            let writeResourceIO = system.write(content: data, toFile: "\(resourcesPath)/\(resourceName)")
            
            return createDirectoryIO.followedBy(writeResourceIO)^.mapLeft { _ in .resource(name: resourceName) }
        }
    }
    
    private func addModules(_ modules: [Module], toPath modulesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
        
        func copy(module: Module, to modulesPath: String) -> EnvIO<FileSystem, PlaygroundBookError, Void> {
            let dest = IOPartial<PlaygroundBookError>.var(String.self)
            return EnvIO { system in
                return binding(
                    dest <- createModuleDirectory(atPath: modulesPath, andName: module.name).provide(system),
                         |<-system.copy(itemPaths: module.sources, to: dest.get).mapLeft { _ in .sources(module: module.name) },
                yield: ())^
            }
        }
        
        func createModuleDirectory(atPath path: String, andName name: String) -> EnvIO<FileSystem, PlaygroundBookError, String> {
            EnvIO { system in
                let modulePath = "\(path)/\(name).playgroundmodule"
                let sourcesPath = "\(modulePath)/Sources"
                
                return system.createDirectory(atPath: sourcesPath)^
                             .mapLeft { _ in .invalidModule(name: name) }
                             .map { _ in sourcesPath }
            }
        }
        
        
        return EnvIO { system in
            modules.k().foldLeft(IO<PlaygroundBookError, ()>.lazy()) { partial, module in
                partial.forEffect(copy(module: module, to: modulesPath).invoke(system))
            }^
        }
    }
}
