import Foundation

struct SyntaxAnalyzer {

    static func parse(content: String) -> [Node]? {
        var parser = SyntaxAnalyzer(content: content)
        let syntax = parser.parse()

        return syntax.contains(Node.raw("")) || !parser.openingDelimiters.isEmpty ? nil : syntax.reduce()
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
                nodes += parse()
            }
            else if let lastToken = openingDelimiters.last, token.isRightDelimiter(lastToken) {
                openingDelimiters.removeLast()
                return [node(for: nodes, parentToken: lastToken)]
            }
            else {
                nodes += [node(for: token, withLine: line)]
            }
        }

        return nodes
    }

    private func node(for token: Token, withLine line: String) -> Node {
        switch token {
        case .markup:
            return .markup(description: nil, line)
        case .comment:
            return .block([.comment(line)])
        default:
            return openingDelimiters.isEmpty ? .block([.code(line)]) : .raw(line.trimmingWhitespaces)
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
            return openingDelimiters.isEmpty ? .block([.comment(content)]) : .raw(content)
        default:
            fatalError("Parent token [\(parent)]: not supported.")
        }
    }
}

// MARK: Helpers
extension Node {
    var isComment: Bool {
        switch self {
        case let .block(nodes):
            return nodes.reduce(true) { acc, node in
                acc && node.isComment
            }
        default:
            return false
        }
    }
}

extension Node.Code {
    var isComment: Bool {
        switch self {
        case .comment: return true
        default: return false
        }
    }
}

extension Node {
    var string: String {
        switch self {
        case let .nef(_, nodes): return nodes.map { $0.string }.joined()
        case let .markup(_, text): return text
        case let .block(nodes): return nodes.map { $0.string }.joined()
        case let .raw(line): return line
        }
    }
}

extension Node.Code {
    var string: String {
        switch self {
        case let .code(code): return code
        case let .comment(lines): return lines
        }
    }
}

// MARK: - Compact syntax tree
extension Array where Element == Node {
    func reduce() -> [Node] {
        return self.reduce([]) { acc, next in
            guard let last = acc.last else { return acc + [next] }

            var result = [Node]()
            result.append(contentsOf: acc)
            result.removeLast()
            result.append(contentsOf: last.combine(next))

            return result
        }
    }
}

// MARK: - How to combine two syntax nodes
extension Node {
    func combine(_ b: Node) -> [Node] {
        switch (self, b) {
        case let (.markup(description, textA), .markup(_, textB)):
            return [.markup(description: description, "\(textA)\n\(textB)")]

        case (.block(var nodesA), .block(let nodesB)):
            guard nodesA.count > 0, nodesB.count == 1,
                  let lastA = nodesA.popLast(),
                  let firstB = nodesB.first else { fatalError("Can not combine \(nodesB) into \(nodesA)") }

            return [.block(nodesA + lastA.combine(firstB))]

        case let (.raw(linesA), .raw(linesB)):
            return [.raw("\(linesA)\n\(linesB)")]

        default:
            return [self, b]
        }
    }
}

extension Node.Code {
    func combine(_ b: Node.Code) -> [Node.Code] {
        switch (self, b) {
        case let (.code(codeA), .code(codeB)):
            return [.code("\(codeA)\n\(codeB)")]
        case let (.comment(textA), .comment(textB)):
            return [.comment("\(textA)\n\(textB)")]
        default:
            return [self, b]
        }
    }
}
