//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels
import NefCore
import BowEffects

public struct RenderEnvironment<A> {
    public typealias NodePrinter = (_ content: String) -> EnvIO<RenderEnvironmentInfo, CoreRenderError, RenderingOutput<A>>
    
    public let console: Console
    public let playgroundSystem: PlaygroundSystem
    public let nodePrinter: NodePrinter

    public init(console: Console, playgroundSystem: PlaygroundSystem, nodePrinter: @escaping NodePrinter) {
        self.console = console
        self.playgroundSystem = playgroundSystem
        self.nodePrinter = nodePrinter
    }
}

public struct RenderEnvironmentInfo {
    public let playground: RenderingURL
    public let page: RenderingURL
    public let isEmpty: Bool
    
    public init(playground: RenderingURL, page: RenderingURL) {
        self.init(playground: playground, page: page, isEmpty: false)
    }
}

// MARK: - helpers
extension RenderEnvironmentInfo {
    internal static var empty: RenderEnvironmentInfo {
        .init(playground: .empty, page: .empty, isEmpty: true)
    }
    
    fileprivate init(playground: RenderingURL, page: RenderingURL, isEmpty: Bool) {
        self.playground = playground
        self.page = page
        self.isEmpty = isEmpty
    }
}

fileprivate extension RenderingURL {
    static var empty: RenderingURL {  .init(url: .init(fileURLWithPath: ""), title: "", escapedTitle: "") }
}
