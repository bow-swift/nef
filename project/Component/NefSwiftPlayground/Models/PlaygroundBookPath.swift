//  Copyright © 2019 The nef Authors.

import Foundation

struct PlaygroundBookPath {
    let name: String
    let path: String
    
    let pageName: String
    let imageReferenceName: String
    let contentsPath: String
    let chapterPath: String
    let pagePath: String
    let templatePagePath: String
    let resourcesPath: String
    let modulesPath: String
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
        
        pageName = name
        imageReferenceName = "nef-playground.png"
        contentsPath = "\(path)/Contents"
        chapterPath = "\(contentsPath)/Chapters/Chapter \(name).playgroundchapter"
        pagePath = "\(chapterPath)/Pages/\(pageName).playgroundpage"
        templatePagePath = "\(chapterPath)/Pages/Template.playgroundpage"
        resourcesPath = "\(contentsPath)/PrivateResources"
        modulesPath = "\(path)/Contents/UserModules"
    }
}
