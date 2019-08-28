//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import AppKit

class PlaygroundBook {
    private let name: String
    private let path: String
    private let storage: Storage
    
    init(name: String, path: String, storage: Storage) {
        self.name = name
        self.path = path
        self.storage = storage
    }
    
    func create(withModules modules: [Module]) {
        let chapterName = "Chapter \(name)"
        let pageName = name
        
        create(chapterName: chapterName, pageName: pageName)
        addModules(modules)
    }
    
    // MARK: private methods
    private func create(chapterName: String, pageName: String) {
        let contentsPath = "\(path)/Contents"
        let resourcesPath = "\(contentsPath)/PrivateResources"
        let chapterPath = "\(contentsPath)/Chapters/\(chapterName).playgroundchapter"
        let pagePath = "\(chapterPath)/Pages/\(pageName).playgroundpage"
        let templatePagePath = "\(chapterPath)/Pages/Template.playgroundpage"
        let imageReference = "nef-playground.png"
        
        makeGeneralManifest(contentsPath: contentsPath, chapterPath: chapterPath, imageReference: imageReference)
        makeChapterManifest(chapterPath: chapterPath, pageName: pageName)
        makePage(path: pagePath)
        makePage(path: templatePagePath)
        makeResources(path: resourcesPath, imageReference: imageReference, base64: AssetsBase64.imageReference)
    }
    
    private func addModules(_ modules: [Module]) {
        let modulesPath = "\(path)/Contents/UserModules"
        
        modules.forEach { module in
            let modulePath = "\(modulesPath)/\(module.name).playgroundmodule"
            let sourcesPath = "\(modulePath)/Sources"
            storage.createFolder(path: sourcesPath)
            
            module.sources.forEach { source in
                let filePath = "\(module.path)/\(source)".resolvePath
                storage.copy(filePath, to: sourcesPath)
            }
        }
    }
    
    private func makeGeneralManifest(contentsPath: String, chapterPath: String, imageReference: String) {
        let manifest = Manifiest.general(chapterName: chapterPath.filename.removeExtension, imageReference: imageReference)
        storage.createFolder(path: contentsPath)
        storage.createFile(withContent: manifest, atPath: "\(contentsPath)/Manifest.plist")
    }
    
    private func makeChapterManifest(chapterPath: String, pageName: String) {
        storage.createFolder(path: chapterPath)
        storage.createFile(withContent: Manifiest.chapter(pageName: pageName), atPath: "\(chapterPath)/Manifest.plist")
    }
    
    private func makePage(path pagePath: String) {
        storage.createFolder(path: pagePath)
        storage.createFile(withContent: PlaygroundCode.header, atPath: "\(pagePath)/main.swift")
        storage.createFile(withContent: Manifiest.page(name: pagePath.filename.removeExtension), atPath: "\(pagePath)/Manifest.plist")
    }
    
    private func makeResources(path resourcesPath: String, imageReference: String, base64: String) {
        storage.createFolder(path: resourcesPath)
        try? Data(base64Encoded: base64)?.write(to: URL(fileURLWithPath: "\(resourcesPath)/\(imageReference)"))
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
