//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels

public struct CoreJekyllEnvironment {
    let permalink: String
    
    public init(permalink: String) {
        self.permalink = permalink
    }
}

public struct CoreMarkdownEnvironment {
    public init() {}
}

public struct CoreCarbonEnvironment {
    let downloader: CarbonDownloader
    let style: CarbonStyle
    
    public init(downloader: CarbonDownloader, style: CarbonStyle) {
        self.downloader = downloader
        self.style = style
    }
}
