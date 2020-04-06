//  Copyright © 2020 The nef Authors.

import NefCommon
import NefModels
import NefCore
import NefRender
import BowEffects

public struct RenderJekyllEnvironment<A> {
    public let persistence: RenderingPersistence<A>
    public let render: Render<A>
    public let jekyllEnvironment: (_ permalink: String) -> RenderEnvironment<A>
    public let renderEnvironment: RenderEnvironment<A>
    
    internal var progressReport: ProgressReport { renderEnvironment.progressReport }
    internal var fileSystem: FileSystem { renderEnvironment.fileSystem }
    
    public init(progressReport: ProgressReport,
                fileSystem: FileSystem,
                persistence: RenderingPersistence<A>,
                xcodePlaygroundSystem: XcodePlaygroundSystem,
                jekyllPrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>) {
        
        self.persistence = persistence
        self.render = Render<A>()
        self.jekyllEnvironment = { permalink in
            RenderEnvironment(
                progressReport: progressReport,
                fileSystem: fileSystem,
                xcodePlaygroundSystem: xcodePlaygroundSystem,
                nodePrinter: Self.nodePrinter(from: jekyllPrinter, permalink: permalink))
        }
        self.renderEnvironment = RenderEnvironment(
            progressReport: progressReport,
            fileSystem: fileSystem,
            xcodePlaygroundSystem: xcodePlaygroundSystem,
            nodePrinter: Self.nodePrinter(from: jekyllPrinter))
    }
    
    // MARK: - helpers
    static var docs: String { "docs" }
    static var data: String { "_data" }
    
    static func permalink(info: RenderEnvironmentInfo) -> IO<CoreRenderError, String> {
        switch info {
        case let .info(playground, page):
            return IO.pure("/\(docs)/\(pagePathComponent(playground: playground, page: page))/")^
        default:
            return IO.raiseError(.renderEmpty)^
        }
    }
    
    static func pagePathComponent(playground: RenderingURL, page: RenderingURL) -> String {
        "\(playground.escapedTitle)/\(page.escapedTitle)"
    }
    
    // MARK: - init <helper>
    private static func nodePrinter(from nodePrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>,
                                    permalink: String) -> RenderEnvironment<A>.NodePrinter {
        { content in
            nodePrinter(content).provide(.init(permalink: permalink)).env()
        }
    }
    
    private static func nodePrinter(from nodePrinter: @escaping (_ content: String) -> EnvIO<CoreJekyllEnvironment, CoreRenderError, RenderingOutput<A>>) -> RenderEnvironment<A>.NodePrinter {
        { content in EnvIO { info in
            permalink(info: info)
                .map(CoreJekyllEnvironment.init)
                .flatMap(nodePrinter(content).provide)
        }}
    }
}
