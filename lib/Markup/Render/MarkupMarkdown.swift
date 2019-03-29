import Foundation

public struct MarkdownGenerator: Render {

    public func render(content: String) -> String? {
        let syntaxTree = SyntaxAnalyzer.parse(content: content)
        guard syntaxTree.count > 0 else { return nil }

        let filteredSyntaxTree = syntaxTree.filter { !$0.isHidden }.reduce()
        filteredSyntaxTree.forEach { print($0) }
        return filteredSyntaxTree.reduce("") { (acc, node) in acc + node.jekyll(permalink: permalink) }
    }
}

// MARK: - Jekyll definition for each node
extension Node {

    func jekyll(permalink: String) -> String
