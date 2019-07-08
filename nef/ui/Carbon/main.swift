//  Copyright © 2019 The nef Authors.

import Common
import Core
import NefCarbon
import NefModels

func main(downloader: CarbonDownloader) {
    let result = arguments(keys: "from", "to", "background", "theme", "size", "font", "show-lines", "show-watermark")
    guard let fromPage = result["from"], let output = result["to"] else {
        Console.help.show(output: CarbonOutput()); exit(-1)
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

// #: - MAIN <launcher - AppKit>
_ = CarbonApplication { downloader in
    main(downloader: downloader)
}
