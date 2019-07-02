//  Copyright © 2019 The nef Authors.

import Foundation
import Markup
import Common

let console = CarbonOutput()

/// Method to render a page into Carbon's images.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to render the snippets.
///   - style: style to apply to export code snippet.
public func renderCarbon(downloader: CarbonDownloader, from filePath: String, to outputPath: String, style: CarbonStyle) {
    defer { CarbonApplication.terminate() }
    guard let content = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) else {
        Console.error(information: "").show(output: console)
        return
    }
    
    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
    guard let trace = carbonGenerator.render(content: content) else {  Console.error(information: "").show(output: console); return }
    
    if carbonGenerator.isValid(trace: trace) {
        Console.success.show(output: console)
    } else {
        Console.error(information: trace).show(output: console)
    }
}

/// Method to render a page into Carbon's images.
///
/// - Parameters:
///   - code: content to export snippet.
///   - style: style to apply to export code snippet.
///   - outputPath: output where to render the snippets.
public func renderCarbon(downloader: CarbonDownloader, code content: String, style: CarbonStyle, outputPath: String) {
    defer { CarbonApplication.terminate() }
    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
    guard let trace = carbonGenerator.render(content: content) else {
        Console.error(information: "").show(output: console)
        return
    }
    
    if carbonGenerator.isValid(trace: trace) {
        Console.success.show(output: console)
    } else {
        Console.error(information: trace).show(output: console)
    }
}
