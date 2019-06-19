//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

let scriptName = "nef-carbon-page"

func main(downloader: CarbonDownloader) {
    let result = arguments(keys: "from", "to", "background", "theme", "size", "font", "show-lines", "show-watermark")
    guard let fromPage = result["from"],
          let output = result["to"] else {
            Console.help.show();
            exit(-1)
    }
    
    let from = "\(fromPage)/Contents.swift"
    let playgroundName = PlaygroundUtils.playgroundName(fromPage: from)
    let to = "\(output)/\(playgroundName)".expandingTildeInPath
    
    let backgroundColor = CarbonStyle.Color(hex: result["background"] ?? "") ?? CarbonStyle.Color.nef
    let theme = CarbonStyle.Theme(rawValue: result["theme"] ?? "") ?? CarbonStyle.Theme.dracula
    let fontType = CarbonStyle.Font(rawValue: result["font"] ?? "") ?? CarbonStyle.Font.firaCode
    let size = CarbonStyle.Size(factor: result["size"] ?? "") ?? CarbonStyle.Size.x2
    let lines = result["show-lines"] == "false" ? false : true
    let watermark = result["show-watermark"] == "false" ? false : true
    
    let style = CarbonStyle(background: backgroundColor, theme: theme, size: size, fontType: fontType, lineNumbers: lines, watermark: watermark)
    renderCarbon(downloader: downloader, from: from, to: to, style: style)
}

/// Method to render a page into Carbon's images.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to render the snippets.
func renderCarbon(downloader: CarbonDownloader, from filePath: String, to outputPath: String, style: CarbonStyle) {
    guard let content = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8) else { Console.error(information: "").show(); return }
    
    let carbonGenerator = CarbonGenerator(downloader: downloader, style: style, output: outputPath)
    guard let trace = carbonGenerator.render(content: content) else {  Console.error(information: "").show(); return }
    
    if carbonGenerator.isValid(trace: trace) {
        Console.success.show()
    } else {
        Console.error(information: trace).show()
    }
    
    CarbonApplication.terminate()
}


// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader: downloader)
}
