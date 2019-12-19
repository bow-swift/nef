//  Copyright © 2019 The nef Authors.

import Foundation

public protocol CoreRender {
    func render(content: String) -> RendererOutput?
}

protocol CoreJekyll {
    func jekyll(permalink: String) -> String
}

protocol CoreMarkdown {
    func markdown() -> String
}

protocol CoreCarbon {
    func carbon(downloader: CarbonCodeDownloader) -> String
}

// Dependencies
extension Node: CoreJekyll {}
extension Node: CoreMarkdown {}
extension Node: CoreCarbon {}

// MARK: - default Render :: render(content:)
protocol InternalRender: CoreRender {
    func render(node: Node) -> String
}

extension InternalRender {
    public func render(content: String) -> RendererOutput? {
        let syntaxTree = SyntaxAnalyzer.parse(content: content)
        guard syntaxTree.count > 0 else { return nil }

        let filteredSyntaxTree = syntaxTree.filter { !$0.isHidden }.reduce()
        let tree = filteredSyntaxTree.map { "\($0)" }.joined(separator: "\n")
        let output = filteredSyntaxTree.reduce("") { (acc, node) in acc + self.render(node: node) }
        return RendererOutput(tree: tree, output: output)
    }
}
