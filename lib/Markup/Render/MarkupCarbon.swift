//  Copyright © 2019 The nef Authors.

import Foundation

public protocol CarbonDownloader: class {
    func carbon(withConfiguration configuration: Carbon, filename: String) -> Result<String, CarbonError>
}

public struct CarbonGenerator: InternalRender {
    private let downloader: CarbonDownloader
    private let style: CarbonStyle
    private let output: String

    public init(downloader: CarbonDownloader, style: CarbonStyle, output: String) {
        self.downloader = downloader
        self.style = style
        self.output = output
    }
    
    public func isValid(trace: String) -> Bool {
        return !trace.contains("☓")
    }
    
    func render(node: Node) -> String {
        return node.carbon(downloader: self)
    }
}

// MARK: - Node Downloader
protocol CarbonCodeDownloader {
    func carbon(code: String) -> String
}

extension CarbonGenerator: CarbonCodeDownloader {
    func carbon(code: String) -> String {
        let configuration = Carbon(code: code, style: style)
        let result = downloader.carbon(withConfiguration: configuration, filename: output)
        
        switch result {
        case let .success(filename):
            return "Downloading Carbon snippet for '\(filename)' ✓"
            
        case let .failure(carbonError):
            return """
                    Downloading Carbon snippet for '\(carbonError.filename)' ☓
                        error: \(carbonError.error)
                        code snippet:
                            \(carbonError.snippet)
                   """
        }
    }
}

// MARK: - Carbon definition for each node
extension Node {
    func carbon(downloader: CarbonCodeDownloader) -> String {
        switch self {
        case let .block(nodes):
            let code = nodes.map { $0.carbon() }.joined()
            guard !code.isEmpty else { return "" }
            return downloader.carbon(code: code)
            
        default:
            return ""
        }
    }
}

extension Node.Code {
    func carbon() -> String {
        switch self {
        case let .code(code):
            return code
            
        case let .comment(text):
            guard !isEmpty else { return "" }
            return text
        }
    }
}
