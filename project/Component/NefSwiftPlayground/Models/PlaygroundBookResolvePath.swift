//  Copyright © 2019 The nef Authors.

import Foundation

struct PlaygroundBookResolvePath {
    let name: String
    let path: String
}

extension PlaygroundBookResolvePath {
    var chapterName: String { "Chapter \(name)" }
    var pageName: String { name }
    var imageReferenceName: String { "nef-playground.png" }
    
    var contentsPath: String { "\(path)/Contents" }
    var chapterPath: String { "\(contentsPath)/Chapters/\(chapterName).playgroundchapter" }
    var pagePath: String { "\(chapterPath)/Pages/\(pageName).playgroundpage" }
    var templatePagePath: String { "\(chapterPath)/Pages/Template.playgroundpage" }
    var resourcesPath: String { "\(contentsPath)/PrivateResources" }
}
