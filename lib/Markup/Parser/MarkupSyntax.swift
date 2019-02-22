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
                let parsedNodes = parse()
                appendNodes(parsedNodes, in: &nodes)
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

    private func appendNodes(_ parsedNodes: [Node], in nodes: inout [Node]) {
        let allNodesAreRaw = parsedNodes.first(where: { !$0.isRaw }) == nil

        if allNodesAreRaw {
            parsedNodes.forEach {
                guard case let .raw(line) = $0 else { return }
                appendNode(in: &nodes, from: .comment, inLine: line)
            }
        } else {
            nodes.append(contentsOf: parsedNodes)
        }
    }

    private func appendNode(in nodes: inout [Node], from token: Token, inLine line: String) {
        func appendCode(in nodes: inout [Node], withLine line: String) {
            if let lastNode = nodes.last, case let .code(lines) = lastNode {
                nodes.removeLast()
                nodes.append(.code(lines+line))
            } else {
                nodes.append(.code(line))
            }
        }

        switch token {
        case .markup:
            return nodes.append(.markup(description: nil, line.clean(["//:"]).trimmingWhitespaces))
        case .comment:
            if openingDelimiters.isEmpty {
                appendCode(in: &nodes, withLine: line)
            } else {
                nodes.append(.raw(line.clean(["//"]).trimmingWhitespaces))
            }
        default:
            if openingDelimiters.isEmpty {
                appendCode(in: &nodes, withLine: line)
            } else {
                nodes.append(.unknown(line.trimmingWhitespaces))
            }
        }
    }

    private func node(for childrens: [Node], parentToken parent: Token) -> Node {
        let content = childrens.map { $0.string }.joined()

        switch parent {
        case let .nefBegin(command):
            return .nef(command: command, childrens)
        case let .markupBegin(description):
            return .markup(description: description, content)
        case .commentBegin:
            let content = content.split(separator: "\n").map({ "// "+$0 }).joined(separator: "\n")
            return .raw(content+"\n")
        default:
            fatalError("Parent token [\(parent)]: not supported.")
        }
    }
}
