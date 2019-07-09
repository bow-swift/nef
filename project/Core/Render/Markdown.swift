//  Copyright © 2019 The nef Authors.

import Foundation

public struct MarkdownGenerator: InternalRender {
    public init() { }
    
    func render(node: Node) -> String {
        return node.markdown()
    }
}

// MARK: - Markdown definition for each node
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
