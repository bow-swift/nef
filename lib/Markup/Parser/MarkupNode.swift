//  Copyright © 2019 The nef Authors.

import Foundation

indirect enum Node: Equatable {
    enum Code: Equatable {
        case code(String)
        case comment(String)
    }

    enum Nef: Equatable {
        enum Command: String, Equatable {
            case header
            case hidden
            case invalid

            static func get(in line: String) -> Command {
                guard line.contains("nef:") else { return .invalid }
                let commandRawValue = line.clean(" ","\n").components(separatedBy: ":").last ?? ""
                return Command(rawValue: commandRawValue) ?? .invalid
            }
        }
    }

    case nef(command: Nef.Command, [Node])
    case markup(description: String?, String)
    case block([Code])
    case raw(String)
}

// MARK: Helpers
// MARK: - compact nodes
extension Array where Element == Node {
    
    func reduce() -> [Node] {
        let compact: [Node] = self.reduce([]) { acc, next in
            guard let last = acc.last else { return acc + [next] }
            var result = acc
            _ = result.popLast()

            return result + last.combine(next)
        }

        return compact.compactMap { $0.trimmingEmptyNodes }
    }
}

extension Node {

    var trimmingEmptyNodes: Node? {
        switch self {
        case let .block(nodes):
            guard let trimmingNodes = nodes.trimmingEmptyNodes else { return nil }
            return .block(trimmingNodes)

        default:
            return self
        }
    }
}

extension Array where Element == Node.Code {

    var trimmingEmptyNodes: [Node.Code]? {
        let leadingTrimming = Array(self.drop { $0.isEmpty })
        var indexFirstTrailingEmptyNode = leadingTrimming.count

        indexFirstTrailingEmptyNode -= (0..<leadingTrimming.count).first { index in
            let inverseIndex = leadingTrimming.count - 1 - index
            return !leadingTrimming[inverseIndex].isEmpty
        } ?? 0

        let trimmingNodes = Array(leadingTrimming.dropLast(leadingTrimming.count - indexFirstTrailingEmptyNode))
        return trimmingNodes.count > 0 ? trimmingNodes : nil
    }
}

extension Node.Code {

    var isEmpty: Bool {
        switch self {
        case let .code(code):
            return code.clean(" ", "\n").isEmpty
        case let .comment(text):
            return text.clean(" ", "\n").isEmpty
        }
    }
}

// MARK: - How to combine two nodes
extension Node {
    func combine(_ b: Node) -> [Node] {
        switch (self, b) {
        case let (.markup(description, textA), .markup(_, textB)):
            guard !textB.isEmpty else { return [self] }
            let isMultiline = description != nil
            return [.markup(description: description, "\(textA)\(isMultiline ? "\n\(textB)" : textB)")]

        case var (.block(nodesA), .block(nodesB)):
            guard let lastA = nodesA.popLast(), nodesB.count > 0 else { fatalError("Can not combine \(nodesB) into \(nodesA) because are empty") }
            let firstB = nodesB.removeFirst()
            return [.block(nodesA + lastA.combine(firstB) + nodesB)]

        case let (.raw(linesA), .raw(linesB)):
            return [.raw("\(linesA)\(linesB)")]

        default:
            return [self, b]
        }
    }
}

extension Node.Code {
    func combine(_ b: Node.Code) -> [Node.Code] {
        guard !self.isEmpty && !b.isEmpty else { return [self, b] } // do not combine empty nodes

        switch (self, b) {
        case let (.code(codeA), .code(codeB)):
            return [.code("\(codeA)\(codeB)")]
        case let (.comment(textA), .comment(textB)):
            return [.comment("\(textA)\(textB)")]

        default:
            return [self, b]
        }
    }
}
