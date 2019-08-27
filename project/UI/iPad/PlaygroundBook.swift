//  Copyright © 2019 The nef Authors.

import Foundation
import Common

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
        let chaptersPath = "\(contentsPath)/Chapters"
        let chapterPath = "\(chaptersPath)/\(chapterName).playgroundchapter"
        let pagePath = "\(chapterPath)/Pages/\(pageName).playgroundpage"
        let templatePagePath = "\(chapterPath)/Pages/Template.playgroundpage"
        
        storage.createFolder(path: pagePath)
        storage.createFolder(path: templatePagePath)
        storage.createFile(withContent: Manifiest.general(chapterName: chapterName), atPath: "\(contentsPath)/Manifest.plist")
        storage.createFile(withContent: Manifiest.chapter(pageName: pageName), atPath: "\(chapterPath)/Manifest.plist")
        
        storage.createFile(withContent: "", atPath: "\(pagePath)/main.swift")
        storage.createFile(withContent: "", atPath: "\(templatePagePath)/main.swift")
        storage.createFile(withContent: Manifiest.page(name: pageName), atPath: "\(pagePath)/Manifest.plist")
        storage.createFile(withContent: Manifiest.page(name: "Template"), atPath: "\(templatePagePath)/Manifest.plist")
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
    
    // MARK: Helpers <Manifiest>
    enum Manifiest {
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
        
        static func general(chapterName: String) -> String {
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
