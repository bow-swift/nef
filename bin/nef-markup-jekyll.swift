//  Copyright © 2019. All rights reserved.

import Foundation

enum Nef {
    enum Command: String, Equatable {
        case header
        case hiden
        case invalid

        static func get(in line: String) -> Command {
            guard line.contains("nef:") else { return .invalid }
            let commandRawValue = line.clean([" ","\n"]).components(separatedBy: ":").last ?? ""
            return Command(rawValue: commandRawValue) ?? .invalid
        }
    }
}

enum Markup {
    indirect enum Node {
        case nef(command: Nef.Command, [Node])
        case markup(title: String?, String)
        case comment(String)
        case code(String)
        case unknown(String)

        var string: String {
            switch self {
            case let .nef(_, nodes): return nodes.map { $0.string }.joined()
            case let .markup(_, description): return description
            case let .comment(description): return description
            case let .code(code): return code
            case let .unknown(description): return description
            }
        }
    }

    enum Token: Equatable {
        case nefBegin(command: Nef.Command)
        case nefEnd
        case markupBegin(title: String)
        case markup
        case comment
        case commentBegin
        case markupCommentEnd
        case line(String)

        func isRightDelimiter(_ token: Token) -> Bool {
            switch (token, self) {
            case (.nefBegin(_), .nefEnd): return true
            case (.markupBegin(_), .markupCommentEnd): return true
            case (.commentBegin, .markupCommentEnd): return true
            default:
                return false
            }
        }

        var isLeftDelimiter: Bool {
            switch self {
            case .nefBegin(_): return true
            case .markupBegin(_): return true
            case .commentBegin: return true
            default:
                return false
            }
        }

        var isDelimiter: Bool {
            switch self {
            case .comment: return false
            case .line(_): return false
            default:
                return true
            }
        }
    }

    struct Tokenizer {
        private let content: String
        private var currentIndex: Int

        init(content: String) {
            self.content = content
            self.currentIndex = 0
        }

        private enum Regex {
            static let nef = (begin: "//[ ]*nef:begin:[a-z]+\n", end: "//[ ]*nef:end[ ]*\n")
            static let multiMarkup = (begin: "/\\*:.*\n")
            static let markup = "//:.*\n"
            static let comment = "//.*\n"
            static let multiComment = (begin: "/\\*.*\n")
            static let markupComment = (end: "\\*/\n")
            static let line = ".*\n"
        }

        private static func token(inLine line: String) -> Markup.Token {
            if let nefBegin = line.substring(pattern: Regex.nef.begin) {
                let command = Nef.Command.get(in: nefBegin.ouput)
                return Markup.Token.nefBegin(command: command)
            }
            if let _ = line.substring(pattern: Regex.nef.end) {
                return Markup.Token.nefEnd
            }
            if let markupBegin = line.substring(pattern: Regex.multiMarkup.begin) {
                let title = markupBegin.ouput.clean([" ","\n"]).components(separatedBy: "/*:").last
                return Markup.Token.markupBegin(title: title ?? "")
            }
            if let _ = line.substring(pattern: Regex.markup) {
                return Markup.Token.markup
            }
            if let _ = line.substring(pattern: Regex.comment) {
                return Markup.Token.comment
            }
            if let _ = line.substring(pattern: Regex.multiComment.begin) {
                return Markup.Token.commentBegin
            }
            if let _ = line.substring(pattern: Regex.markupComment.end) {
                return Markup.Token.markupCommentEnd
            }

            return Markup.Token.line(line)
        }

        private func nextLine() -> SubstringType? {
            return content.advance(currentIndex).substring(pattern: Regex.line)
        }

        mutating func nextToken() -> (token: Markup.Token, line: String)? {
            guard let line = nextLine() else { return nil }

            let token = Tokenizer.token(inLine: line.ouput)
            currentIndex += line.range.location + line.range.length

            return (token, line.ouput)
        }
    }

    struct Parser {
        private var tokenizer: Tokenizer
        private var openingDelimiters: [Markup.Token]

        static func parse(content: String) -> [Markup.Node] {
            var parser = Parser(content: content)
            return parser.parse()
        }

        private init(content: String) {
            tokenizer = Tokenizer(content: content)
            openingDelimiters = []
        }

        mutating func parse() -> [Markup.Node] {
            var nodes = [Markup.Node]()

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
                    switch token {
                    case .markup:
                        nodes.append(.markup(title: nil, line))
                    case .comment:
                        nodes.append(.comment(line))
                    default:
                        nodes.append(openingDelimiters.isEmpty ? .code(line) : .unknown(line))
                    }
                }
            }

            return nodes
        }

        private func node(for childrens: [Markup.Node], parentToken parent: Markup.Token) -> Markup.Node {
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
}

// MARK: Helpers
// MARK: - <string>
typealias SubstringType = (ouput: String, range: NSRange)

extension String {
    func substring(pattern: String) -> SubstringType? {
        let range = NSRange(location: 0, length: self.utf8.count)
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
            let match = regex.firstMatch(in: self, options: [], range: range) else { return nil }

        let output = NSString(string: self).substring(with: match.range) as String

        return (output, match.range)
    }

    func advance(_ offset: Int) -> String {
        return NSString(string: self).substring(from: offset) as String
    }

    func substring(length: Int) -> String {
        return NSString(string: self).substring(to: min(length, self.count)) as String
    }

    func clean(_ ocurrences: [String]) -> String {
        return ocurrences.reduce(self) { (output, ocurrence) in
            output.replacingOccurrences(of: ocurrence, with: "")
        }
    }
}
