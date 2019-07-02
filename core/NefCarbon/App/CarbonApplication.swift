//  Copyright © 2019 The nef Authors.

import AppKit
import Markup

public class CarbonApplication {
    private let app = NSApplication.shared
    private let appDelegate: CarbonAppDelegate
    private let assembler = CarbonAssembler()
    
    public init(main: @escaping (CarbonDownloader) -> Void) {
        self.appDelegate = CarbonAppDelegate(main: main, provider: assembler)
        app.delegate = appDelegate
        app.run()
    }
    
    static func terminate() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: Assembler
protocol CarbonProvider {
    func resolveCarbonDownloader(view: CarbonWebView & CarbonView) -> CarbonDownloader
}

class CarbonAssembler: CarbonProvider {
    func resolveCarbonDownloader(view: CarbonWebView & CarbonView) -> CarbonDownloader {
        let downloader = CarbonSyncDownloader(view: view)
        view.carbonDelegate = downloader
        return downloader
    }
}
