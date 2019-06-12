//  Copyright © 2019 The nef Authors.

import Foundation

public protocol CarbonDownloader: class {
    func carbon(withConfiguration configuration: Carbon, filename: String) -> Result<String, CarbonError>
}

public struct CarbonGenerator: InternalRender {
    let downloader: CarbonDownloader
    let style: CarbonStyle
    let output: String

    public init(downloader: CarbonDownloader, style: CarbonStyle, output: String) {
        self.downloader = downloader
        self.style = style
        self.output = output
    }
    
    func render(node: Node) -> String {
        node.carbon(downloader: self)
        return ""
    }
}

extension CarbonGenerator: CarbonCodeDownloader {
    
    func carbon(code: String) {
        let configuration = Carbon(code: code, style: style)
        let result = self.downloader.carbon(withConfiguration: configuration, filename: "\(self.output)-\(2)")
        if case .failure(let e) = result {
                
        }
    }
}

// MARK: - Carbon definition for each node

protocol CarbonCodeDownloader {
    func carbon(code: String)
}

enum CarbonNodeError: Error {
    case invalid
}

extension Node {
    
    func carbon(downloader: CarbonCodeDownloader) -> CarbonNodeError? {
        switch self {
        case let .block(nodes):
            let code = nodes.map { $0.carbon() }.joined()
            guard !code.isEmpty else { return nil }
            downloader.carbon(code: code)
            return nil
            
        default:
            return nil
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
