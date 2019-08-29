//  Copyright © 2019 The nef Authors.

import Foundation
import Common
import Core
import NefModels
import NefCarbon

let scriptName = "nef-carbon-page"
let console = CarbonOutput()

func main(downloader: CarbonDownloader) {
    let result = arguments(keys: "from", "to", "background", "theme", "size", "font", "show-lines", "show-watermark")
    guard let fromPage = result["from"], let output = result["to"] else {
        console.printHelp()
        exit(-1)
    }
    
    let from = "\(fromPage)/Contents.swift"
    let playgroundName = PlaygroundUtils.playgroundName(fromPage: from)
    let to = "\(output)/\(playgroundName)".expandingTildeInPath
    
    let backgroundColor = CarbonStyle.Color(hex: result["background"] ?? "") ?? CarbonStyle.Color(default: result["background"] ?? "") ?? CarbonStyle.Color.nef
    let theme = CarbonStyle.Theme(rawValue: result["theme"] ?? "") ?? CarbonStyle.Theme.dracula
    let fontType = CarbonStyle.Font(rawValue: result["font"] ?? "") ?? CarbonStyle.Font.firaCode
    let size = CarbonStyle.Size(factor: result["size"] ?? "") ?? CarbonStyle.Size.x2
    let lines = result["show-lines"] == "false" ? false : true
    let watermark = result["show-watermark"] == "false" ? false : true
    
    let style = CarbonStyle(background: backgroundColor, theme: theme, size: size, fontType: fontType, lineNumbers: lines, watermark: watermark)
    renderCarbon(downloader: downloader, from: from, to: to, style: style)
}

/// Renders a page into multiple Carbon images.
///
/// - Parameters:
///   - filePath: input page in Xcode playground format.
///   - outputPath: output where to render the snippets.
///   - style: style to apply to export code snippet.
private func renderCarbon(downloader: CarbonDownloader, from filePath: String, to outputPath: String, style: CarbonStyle) {
    guard let content = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) else {
        consoleError(information: ""); return
    }
    
    renderCarbon(downloader: downloader,
                 code: content,
                 style: style,
                 outputPath: outputPath,
                 success: consoleSuccess,
                 failure: consoleError)
}

private func consoleSuccess() {
    console.printSuccess()
    CarbonApplication.terminate()
}

private func consoleError(information: String) {
    console.printError(information: "")
    CarbonApplication.terminate()
}

// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader: downloader)
}
