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

public enum RenderEnvironmentInfo {
    case info(playground: RenderingURL, page: RenderingURL)
    case empty
    
    public var data: (playground: RenderingURL, page: RenderingURL)? {
        switch self {
        case let .info(playground, page): return (playground, page)
        default: return nil
        }
    }
}
