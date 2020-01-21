//  Copyright © 2020 The nef Authors.

import Foundation
import NefModels

public struct CoreJekyllEnvironment {
    let permalink: String
}

public struct CoreMarkdownEnvironment {}

public struct CoreCarbonEnvironment {
    let downloader: CarbonDownloader
    let style: CarbonStyle
}
