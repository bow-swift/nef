//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import AppKit

enum PlaygroundBookError: Error {
    case manifest
    case invalidModule
    case page
    case resource
}

class PlaygroundBook {
    private let name: String
    private let path: String
    private let storage: Storage
    
    init(name: String, path: String, storage: Storage) {
        self.name = name
        self.path = path
        self.storage = storage
    }
    
    func create(withModules modules: [Module]) -> Result<Void, PlaygroundBookError> {
        let chapterName = "Chapter \(name)"
        let pageName = name
        
        return create(chapterName: chapterName, pageName: pageName)
                .flatMap { _ in addModules(modules) }
    }
    
    // MARK: private methods
    private func create(chapterName: String, pageName: String) -> Result<Void, PlaygroundBookError> {
        let contentsPath = "\(path)/Contents"
        let resourcesPath = "\(contentsPath)/PrivateResources"
        let chapterPath = "\(contentsPath)/Chapters/\(chapterName).playgroundchapter"
        let pagePath = "\(chapterPath)/Pages/\(pageName).playgroundpage"
        let templatePagePath = "\(chapterPath)/Pages/Template.playgroundpage"
        let imageReference = "nef-playground.png"
        
        return makeGeneralManifest(contentsPath: contentsPath, chapterPath: chapterPath, imageReference: imageReference)
            .flatMap { _ in makeChapterManifest(chapterPath: chapterPath, pageName: pageName) }
            .flatMap { _ in makePage(path: pagePath) }
            .flatMap { _ in makePage(path: templatePagePath) }
            .flatMap { _ in makeResources(path: resourcesPath, imageReference: imageReference, base64: AssetsBase64.imageReference) }
    }
    
    private func addModules(_ modules: [Module]) -> Result<Void, PlaygroundBookError> {
        let modulesPath = "\(path)/Contents/UserModules"
        
        let copiedModules = modules.reduce(true) { partial, module in
            guard partial else { return false }
            
            let modulePath = "\(modulesPath)/\(module.name).playgroundmodule"
            let sourcesPath = "\(modulePath)/Sources"
            storage.createFolder(path: sourcesPath)
            
            let copiedModule = module.sources.reduce(true) { (partial, source) in
                guard partial else { return false }
                
                let filePath = "\(module.path)/\(source)".resolvePath
                let result = storage.copy(filePath, to: sourcesPath)
                let copiedFile = (try? result.get()) != nil
                return copiedFile
            }
            
            return copiedModule
        }
        
        return copiedModules ? .success(()) : .failure(.resource)
    }
    
    private func makeGeneralManifest(contentsPath: String, chapterPath: String, imageReference: String) -> Result<Void, PlaygroundBookError> {
        let manifest = Manifiest.general(chapterName: chapterPath.filename.removeExtension, imageReference: imageReference)
        return makeManifest(manifest: manifest, folderPath: contentsPath)
    }
    
    private func makeChapterManifest(chapterPath: String, pageName: String) -> Result<Void, PlaygroundBookError> {
        let manifest = Manifiest.chapter(pageName: pageName)
        return makeManifest(manifest: manifest, folderPath: chapterPath)
    }
    
    private func makeManifest(manifest: String, folderPath: String) -> Result<Void, PlaygroundBookError> {
        storage.createFolder(path: folderPath)
        let manifestResult = storage.createFile(withContent: manifest, atPath: "\(folderPath)/Manifest.plist")
        
        return manifestResult.flatMap { _ in .success(()) }
                             .flatMapError { _ in .failure(PlaygroundBookError.manifest) }
    }
    
    private func makePage(path pagePath: String) -> Result<Void, PlaygroundBookError> {
        let swiftCode = PlaygroundCode.header
        let manifest  = Manifiest.page(name: pagePath.filename.removeExtension)
        
        storage.createFolder(path: pagePath)
        
        let fileResult = storage.createFile(withContent: swiftCode, atPath: "\(pagePath)/main.swift")
                                .flatMap { _ in .success(()) }.flatMapError { _ in .failure(PlaygroundBookError.page) }
        
        let manifestResult = storage.createFile(withContent: manifest, atPath: "\(pagePath)/Manifest.plist")
                                    .flatMap { _ in .success(()) }.flatMapError { _ in .failure(PlaygroundBookError.page) }
        
        return fileResult.flatMap { _ in manifestResult }
    }
    
    private func makeResources(path resourcesPath: String, imageReference: String, base64: String) -> Result<Void, PlaygroundBookError> {
        storage.createFolder(path: resourcesPath)
        guard let data = Data(base64Encoded: base64),
              let _ = try? data.write(to: URL(fileURLWithPath: "\(resourcesPath)/\(imageReference)")) else {
            return .failure(.resource)
        }

        return .success(())
    }
    
    // MARK: Constants <Code>
    private enum PlaygroundCode {
        static let header = """
                            //#-hidden-code
                            import UIKit
                            import PlaygroundSupport

                            let liveView = UIView()
                            
                            PlaygroundPage.current.liveView = liveView
                            PlaygroundPage.current.needsIndefiniteExecution = true

                            enum PlaygroundColor {
                                static let nef = UIColor(red: 140/255.0, green: 68/255.0, blue: 1, alpha: 1)
                                static let bow = UIColor(red: 213/255.0, green: 64/255.0, blue: 72/255.0, alpha: 1)
                                static let white = UIColor.white
                                static let black = UIColor.black
                                static let yellow = UIColor(red: 1, green: 237/255.0, blue: 117/255.0, alpha: 1)
                                static let green = UIColor(red: 110/255.0, green: 240/255.0, blue: 167/255.0, alpha: 1)
                                static let blue = UIColor(red: 66/255.0, green: 197/255.0, blue: 1, alpha: 1)
                                static let orange = UIColor(red: 1, green: 159/255.0, blue: 70/255.0, alpha: 1)
                            }
                            //#-end-hidden-code
                            liveView.backgroundColor = PlaygroundColor.nef

                            """
                            
    }
    
    // MARK: Constants <Manifiest>
    private enum Manifiest {
        static let header = """
                            <?xml version="1.0" encoding="UTF-8"?>
                             <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                             <plist version="1.0">
                            """
        
        static func page(name: String) -> String {
            """
            \(Manifiest.header)
            <dict>
                <key>Name</key>
                <string>\(name)</string>
                <key>LiveViewEdgeToEdge</key>
                <true/>
                <key>LiveViewMode</key>
                <string>VisibleByDefault</string>
            </dict>
            </plist>
            """
        }
        
        static func chapter(pageName: String) -> String {
            """
            \(Manifiest.header)
            <dict>
                <key>Name</key>
                <string>\(pageName)</string>
                <key>TemplatePageFilename</key>
                <string>Template.playgroundpage</string>
                <key>InitialUserPages</key>
                <array>
                    <string>\(pageName).playgroundpage</string>
                </array>
            </dict>
            </plist>
            """
        }
        
        static func general(chapterName: String, imageReference: String) -> String {
            """
            \(Manifiest.header)
            <dict>
                <key>Chapters</key>
                <array>
                    <string>\(chapterName).playgroundchapter</string>
                </array>
                <key>ContentIdentifier</key>
                <string>com.apple.playgrounds.blank</string>
                <key>ContentVersion</key>
                <string>1.0</string>
                <key>DeploymentTarget</key>
                <string>ios11.0</string>
                <key>DevelopmentRegion</key>
                <string>en</string>
                <key>ImageReference</key>
                <string>\(imageReference)</string>
                <key>Name</key>
                <string>Blank</string>
                <key>SwiftVersion</key>
                <string>5.0</string>
                <key>Version</key>
                <string>6.0</string>
                <key>UserAutoImportedAuxiliaryModules</key>
                <array/>
                <key>UserModuleMode</key>
                <string>Full</string>
            </dict>
            </plist>
            """
        }
    }
}
