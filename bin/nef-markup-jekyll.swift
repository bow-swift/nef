//  Copyright © 2019. All rights reserved.

import Foundation

let filePath = "/Users/miguelangel/Desktop/Documentacion/Type Clases.playground/Pages/Intro.xcplaygroundpage/Contents.swift"

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
    enum Node {
        case nef(command: Nef.Command, [Node])
        case markup(title: String, String)
        case comment(String)
        case ignore(String)
        case text(String)
    }

    enum Token: Equatable, CustomDebugStringConvertible {
        case nefBegin(command: Nef.Command)
        case nefEnd(command: Nef.Command)
        case markupBegin(title: String)
        case comment
        case commentBegin
        case markupCommentEnd
        case line(String)

        static func == (lhs: Token, rhs: Token) -> Bool {
            switch (lhs, rhs) {
            case let (.nefBegin(command1), .nefBegin(command2)):
                return command1 == command2
            case let (.nefEnd(command1), .nefEnd(command2)):
                return command1 == command2
            case let (.markupBegin(title1), .markupBegin(title2)):
                return title1 == title2
            case let (.line(body1), .line(body2)):
                return body1 == body2
            case (.commentBegin, .commentBegin): return true
            case (.markupCommentEnd, .markupCommentEnd): return true
            default:
                return false
            }
        }

        var debugDescription: String {
            switch self {
            case let .nefBegin(command): return "nef(begin: \(command))"
            case let .nefEnd(command): return "nef(end: \(command))"
            case let .markupBegin(title): return "markup(begin: \(title))"
            case .comment: return "single-comment"
            case .commentBegin: return "comment(begin)"
            case .markupCommentEnd: return "comment-markup(end)"
            case let .line(body): return "line(body: \(body.clean(["\n"]).substring(length: 50)))"
            }
        }
    }

    enum Parser {
        private enum Regex {
            static let nef = (begin: "//[ ]?nef:begin:[a-z]+\n", end: "//[ ]?nef:end:[a-z]+\n")
            static let markup = (begin: "/\\*:[.]*\n")
            static let comment = "//.*\n"
            static let multiComment = (begin: "/\\*.*\n")
            static let markupComment = (end: "\\*/\n")
            static let line = ".*\n"
        }

        static func token(inLine line: String) -> Markup.Token {
            if let nefBegin = line.substring(pattern: Regex.nef.begin) {
                let command = Nef.Command.get(in: nefBegin.ouput)
                return Markup.Token.nefBegin(command: command)
            }
            if let nefEnd = line.substring(pattern: Regex.nef.end) {
                let command = Nef.Command.get(in: nefEnd.ouput)
                return Markup.Token.nefEnd(command: command)
            }
            if let markupBegin = line.substring(pattern: Regex.markup.begin) {
                let title = markupBegin.ouput.clean([" ","\n"]).components(separatedBy: "/*:").last
                return Markup.Token.markupBegin(title: title ?? "")
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

        static func nextLine(_ content: String) -> SubstringType? {
            return content.substring(pattern: Markup.Parser.Regex.line)
        }
    }
}

struct MarkupTokenizer {
    private let content: String
    private var openingDelimiters: [Markup.Token] = []

    init(_ content: String) {
        self.content = content
    }

    func tokenizer() -> [Markup.Token] {
        var content = self.content
        var tokens = [Markup.Token]()

        while let line = Markup.Parser.nextLine(content) {
            content = content.advance(line.range.location + line.range.length)

            let token = Markup.Parser.token(inLine: line.ouput)
            tokens.append(token)
        }

        return tokens
    }
}

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

// MARK: - MAIN
func parser(path: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return }

    MarkupTokenizer(content).tokenizer().forEach { print($0) }
}

parser(path: filePath)
