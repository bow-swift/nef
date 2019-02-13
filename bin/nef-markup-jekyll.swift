//  Copyright © 2019. All rights reserved.

import Foundation

let DEBUG = false

enum Markup { }

// MARK: Markup.Node
extension Markup {

    indirect enum Node: Equatable {
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

    enum Nef {
        enum Command: String, Equatable {
            case header
            case hidden
            case invalid

            static func get(in line: String) -> Command {
                guard line.contains("nef:") else { return .invalid }
                let commandRawValue = line.clean([" ","\n"]).components(separatedBy: ":").last ?? ""

                return Command(rawValue: commandRawValue) ?? .invalid
            }
        }
    }
}

//-----------------------------------------------------------------

// MARK: Markup - Lexical Analysis
extension Markup {

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

        mutating func nextToken() -> (token: Markup.Token, line: String)? {
            guard let line = nextLine() else { return nil }

            let token = Tokenizer.token(inLine: line.ouput)
            currentIndex += line.range.location + line.range.length

            return (token, line.ouput)
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
    }
}

//-----------------------------------------------------------------

// MARK: Markup - Syntax Analysis
extension Markup {

    struct Parser {

        static func parse(content: String) -> [Markup.Node]? {
            var parser = Parser(content: content)
            let syntax = parser.parse()

            return syntax.contains(Markup.Node.unknown("")) || !parser.openingDelimiters.isEmpty ? nil : syntax
        }

        private var tokenizer: Tokenizer
        private var openingDelimiters: [Markup.Token]

        private init(content: String) {
            tokenizer = Tokenizer(content: content)
            openingDelimiters = []
        }

        private mutating func parse() -> [Markup.Node] {
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
                    appendNode(in: &nodes, from: token, inLine: line)
                }
            }

            return nodes
        }

        private func appendNode(in nodes: inout [Markup.Node], from token: Markup.Token, inLine line: String) {
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

//-----------------------------------------------------------------

/// Code Generation
protocol Render {
    static func render(content: String) -> String?
}

// MARK: Markup - Jekyll file generation
struct RenderJekyll: Render {
    static func render(content: String) -> String? {
        guard let syntax = Markup.Parser.parse(content: content) else { return nil }
        if DEBUG { syntax.forEach { print($0) } }
        return syntax.reduce("") { (acc, node) in acc + node.jekyll }
    }
}

extension Markup.Node {
    var jekyll: String {
        switch self {
        case let .nef(command, nodes):
            return command.jekyll(nodes: nodes)

        case let .markup(_, description):
            return "\n\(description)"

        case let .comment(description):
            return description

        case let .code(code):
            guard !code.clean([" ", "\n"]).isEmpty else { return "" }
            return "\n```swift\n\(code)```\n"

        case let .unknown(description):
            fatalError("Found .unknown node in file with content: \(description.clean(["\n"]).substring(length: 50))")
        }
    }
}

extension Markup.Nef.Command {
    func jekyll(nodes: [Markup.Node]) -> String {
        switch self {
        case .header:
            return nodes.map{ $0.jekyll }.joined()
        case .hidden:
            return ""
        case .invalid:
            fatalError("Found .invalid command in nef: \(nodes).")
        }
    }
}

//-----------------------------------------------------------------

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

    var trimmingWhitespaces: String {
        return trimmingCharacters(in: .whitespaces)
    }
}

//-----------------------------------------------------------------

// MARK: MAIN

func renderJekyll(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    print("File: \(filePath)\nOutput: \(outputPath)")
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let rendered = RenderJekyll.render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { printError(); return }

    printSuccess()
}

private func printError() {
    print("ERROR")
}

private func printSuccess() {
    print("SUCCESS")
}

private func printHelp() {
    print("HELP")
}

// MARK: - Console
private func arguments() -> (from: String, to: String)? {
    guard CommandLine.arguments.count == 3 else { return nil }
    return (CommandLine.arguments[1], CommandLine.arguments[2])
}

if let (from, to) = arguments() {
    renderJekyll(from: from, to: to)
} else {
    printHelp()
    exit(-1)
}
