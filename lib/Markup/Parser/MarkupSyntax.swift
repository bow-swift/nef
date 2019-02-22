import Foundation

struct SyntaxAnalyzer {

    static func parse(content: String) -> [Node]? {
        var parser = SyntaxAnalyzer(content: content)
        let syntax = parser.parse()

        return syntax.contains(Node.unknown("")) || !parser.openingDelimiters.isEmpty ? nil : syntax
    }

    private var tokenizer: LexicalAnalyzer
    private var openingDelimiters: [Token]

    private init(content: String) {
        tokenizer = LexicalAnalyzer(content: content)
        openingDelimiters = []
    }

    private mutating func parse() -> [Node] {
        var nodes = [Node]()

        while let (token, line) = tokenizer.nextToken() {
            if token.isLeftDelimiter {
                openingDelimiters.append(token)
                nodes.append(contentsOf: parse())
            }
            else if let lastToken = openingDelimiters.last, token.isRightDelimiter(lastToken) {
                openingDelimiters.removeLast()
                return [node(for: nodes, parentToken: lastToken)]
            }
            else {
                appendNode(in: &nodes, from: token, inLine: line)
            }
        }

        return nodes
    }

    private func appendNode(in nodes: inout [Node], from token: Token, inLine line: String) {
        switch token {
        case .markup:
            return nodes.append(.markup(title: nil, line.clean(["//:"]).trimmingWhitespaces))

        case .comment:
            return nodes.append(.comment(line.trimmingWhitespaces))

        default:
            let isCodeNode = openingDelimiters.isEmpty
            if isCodeNode{
                if let lastNode = nodes.last, case let .code(lines) = lastNode {
                    nodes.removeLast()
                    nodes.append(.code(lines+line))
                } else {
                    nodes.append(.code(line))
                }
            } else {
                nodes.append(.unknown(line.trimmingWhitespaces))
            }
        }
    }

    private func node(for childrens: [Node], parentToken parent: Token) -> Node {
        let description = childrens.map { $0.string }.joined()

        switch parent {
        case let .nefBegin(command):
            return .nef(command: command, childrens)
        case let .markupBegin(title):
            return .markup(title: title, description)
        case .commentBegin:
            return .comment(description)
        default:
            fatalError("Parent token [\(parent)]: not supported.")
        }
    }
}
