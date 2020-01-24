//  Copyright © 2019 The nef Authors.

import NefModels
import Bow
import BowEffects

public protocol CarbonDownloader {
    func carbon(configuration: CarbonModel) -> IO<CarbonError, Image>
}


extension NodeProcessor where D == CoreCarbonEnvironment, A == Image {
    static var carbon: NodeProcessor {
        func render(node: Node) -> EnvIO<D, CoreRenderError, A> {
            EnvIO { env in
                node.carbon(downloader: env.downloader, style: env.style)
            }
        }

        func merge(nodes: [A]) -> EnvIO<D, CoreRenderError, NEA<A>> {
            let nodes = nodes.filter { !$0.isEmpty }
            guard !nodes.isEmpty else { return EnvIO.pure(NEA.of(.empty))^ }
            return EnvIO.pure(NEA.fromArrayUnsafe(nodes))^
        }

        return .init(render: render, merge: merge)
    }
}


// MARK: - node definition <carbon>
extension Node {
    func carbon(downloader: CarbonDownloader, style: CarbonStyle) -> IO<CoreRenderError, Image> {
        switch self {
        case let .block(nodes):
            let code = nodes.map { $0.carbon() }.joined()
            guard !code.isEmpty else { return IO.raiseError(.renderEmpty)^ }
            let configuration = CarbonModel(code: code, style: style)
            return downloader.carbon(configuration: configuration).mapLeft { _ in .renderNode }
            
        default:
            return IO.pure(Image.empty)^
        }
    }
}

extension Node.Code {
    func carbon() -> String {
        switch self {
        case let .code(code):
            return code
            
        case let .comment(text):
            guard !isEmpty else { return "" }
            return text
        }
    }
}
