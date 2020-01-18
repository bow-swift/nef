//  Copyright © 2020 The nef Authors.

import Foundation
import NefUtils
import NefModels
import NefCore
import NefRender

public struct RenderJekyllEnvironment {
    public let renderEnvironment: RenderEnvironment
    public let jekyllPrinter: (_ permalink: String) -> CoreRender
    public let permalink: (RendererPage) -> String
    
    public init(console: Console,
                playgroundSystem: PlaygroundSystem,
                fileSystem: FileSystem,
                nodePrinter: @escaping (RendererPage) -> CoreRender,
                jekyllPrinter: @escaping (_ permalink: String) -> CoreRender,
                permalink: @escaping (RendererPage) -> String) {
        
        self.renderEnvironment = RenderEnvironment(console: console, playgroundSystem: playgroundSystem, fileSystem: fileSystem, nodePrinter: nodePrinter)
        self.jekyllPrinter = jekyllPrinter
        self.permalink = permalink
    }
}

extension RenderJekyllEnvironment {
    func renderEnvironment(permalink: String) -> RenderEnvironment {
        renderEnvironment.copy(with: { _ in self.jekyllPrinter(permalink) }, for: \RenderEnvironment.nodePrinter)
    }
}
