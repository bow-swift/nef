//  Copyright © 2019 The nef Authors.

import Foundation
import Markup

public class CarbonAssembler: CarbonProvider, CarbonAppDelegateAssembler {
    public init() {}
}

// MARK: dependency injection

extension CarbonAssembler {
    public func resolveCarbonDownloader(view: CarbonView) -> CarbonDownloader {
        let downloader = CarbonSyncDownloader(view: view)
        view.carbonDelegate = downloader
        return downloader
    }
    
    public func resolveCarbonView(frame: NSRect) -> CarbonView {
        return CarbonWebView(frame: frame)
    }
}
