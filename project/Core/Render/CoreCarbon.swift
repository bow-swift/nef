//  Copyright © 2019 The nef Authors.

import AppKit
import NefModels
import Bow
import BowEffects

public protocol CarbonDownloader {
    func carbon(configuration: CarbonModel) -> IO<CarbonError, NSImage>
}

extension NodeProcessor where D == CoreCarbonEnvironment, A == NSImage {
    static var carbon: NodeProcessor {
        func render(node: Node) -> EnvIO<D, CoreRenderError, A> {
            EnvIO { env in
                node.carbon(downloader: env.downloader, style: env.style)
            }
        }

        func merge(nodes: [A]) -> EnvIO<D, CoreRenderError, NEA<A>> {
            let nodes = nodes.filter { image in !image.isEmpty }
            guard !nodes.isEmpty else { return EnvIO.raiseError(.emptyNode)^ }
            return EnvIO.pure(NEA(head: nodes[0], tail: Array(nodes[1...])))^
        }

        return .init(render: render, merge: merge)
    }
}


// MARK: - node definition <carbon>
extension Node {
    func carbon(downloader: CarbonDownloader, style: CarbonStyle) -> IO<CoreRenderError, NSImage> {
        switch self {
        case let .block(nodes):
            let code = nodes.map { $0.carbon() }.joined()
            guard !code.isEmpty else { return IO.raiseError(.emptyNode)^ }
            let configuration = CarbonModel(code: code, style: style)
            return downloader.carbon(configuration: configuration).mapLeft { _ in .renderNode }
            
        default:
            return IO.pure(NSImage.empty)^
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

// MARK: private utils
extension NSImage {
    static var empty: NSImage { NSImage(size: .zero) }
    var isEmpty: Bool { size == .zero }
}
