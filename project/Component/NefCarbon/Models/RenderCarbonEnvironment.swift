//  Copyright © 2020 The nef Authors.

import AppKit
import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderCarbonEnvironment<A> {
    public let fileSystem: FileSystem
    public let persistence: RenderingPersistence<A>
    public let render: Render<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    public init(console: Console,
                fileSystem: FileSystem,
                persistence: RenderingPersistence<A>,
                playgroundSystem: PlaygroundSystem,
                style: CarbonStyle,
                carbonPrinter: @escaping (_ content: String) -> EnvIO<CoreCarbonEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        func environment(style: CarbonStyle) -> CoreCarbonEnvironment {
            .init(downloader: CarbonAssembler().resolveCarbonDownloader(),
                  style: style)
        }
        
        self.fileSystem = fileSystem
        self.persistence = persistence
        self.render = Render<A>()
        self.renderEnvironment = RenderEnvironment(console: console,
                                                   playgroundSystem: playgroundSystem,
                                                   nodePrinter: { content in carbonPrinter(content).provide(environment(style: style)).env() })
    }
}
