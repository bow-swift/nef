//  Copyright © 2019 The nef Authors.

import Foundation
import Bow
import BowEffects

extension NodeProcessor where D == CoreMarkdownEnvironment, A == String {
    static var markdown: NodeProcessor {
        func render(node: Node) -> EnvIO<D, CoreRenderError, A> {
            EnvIO.pure(node.markdown())^
        }
        
        func merge(nodes: [A]) -> EnvIO<D, CoreRenderError, NEA<A>> {
            let data = nodes.combineAll()
            guard !data.isEmpty else { return EnvIO.raiseError(.renderEmpty)^ }
            return EnvIO.pure(NEA.of(data))^
        }
        
        return .init(render: render, merge: merge)
    }
}


// MARK: - node definition <markdown>
extension Node {
    func markdown() -> String {
        switch self {
        case let .nef(command, nodes):
            return command.markdown(nodes: nodes)

        case let .markup(_, text):
            let textMarkdown = text.components(separatedBy: "\n").map { line in
                guard (line.substring(pattern: "^[ ]*[#]+.*") != nil) else { return line }
                return line.trimmingLeftWhitespaces
            }.joined(separator: "\n")

            return "\n\(textMarkdown)"

        case let .block(nodes):
            let nodesMarkdown = nodes.map { $0.markdown() }.joined()
            guard !nodesMarkdown.isEmpty else { return "" }
            return "\n```swift\n\(nodesMarkdown)```\n"

        case let .raw(description):
            return description
        }
    }
}

extension Node.Nef.Command {
    func markdown(nodes: [Node]) -> String {
        switch self {
        case .header:
            return ""
        case .hidden:
            return ""
        case .invalid:
            fatalError("error: found .invalid command in nef: \(nodes).")
        }
    }
}

extension Node.Code {
    func markdown() -> String {
        switch self {
        case let .code(code):
            return code

        case let .comment(text):
            guard !isEmpty else { return "" }
            return text
        }
    }
}
