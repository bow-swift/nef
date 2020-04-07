//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels
import NefCore
import BowEffects

public struct RenderEnvironment<A> {
    public typealias NodePrinter = (_ content: String) -> EnvIO<RenderEnvironmentInfo, CoreRenderError, RenderingOutput<A>>
    
    public let progressReport: ProgressReport
    public let fileSystem: FileSystem
    public let xcodePlaygroundSystem: XcodePlaygroundSystem
    public let nodePrinter: NodePrinter

    public init(progressReport: ProgressReport,
                fileSystem: FileSystem,
                xcodePlaygroundSystem: XcodePlaygroundSystem,
                nodePrinter: @escaping NodePrinter) {
        self.progressReport = progressReport
        self.fileSystem = fileSystem
        self.xcodePlaygroundSystem = xcodePlaygroundSystem
        self.nodePrinter = nodePrinter
    }
}

public enum RenderEnvironmentInfo {
    case info(playground: RenderingURL, page: RenderingURL)
    case empty
    
    public var pathComponent: String {
        guard let data = data else { return "" }
        return "\(data.playground.escapedTitle)/\(data.page.escapedTitle)"
    }
    
    var data: (playground: RenderingURL, page: RenderingURL)? {
        switch self {
        case let .info(playground, page):
            return (playground, page)
        default:
            return nil
        }
    }
}
