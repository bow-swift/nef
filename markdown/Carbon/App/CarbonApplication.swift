//  Copyright © 2019 The nef Authors.

import AppKit
import Markup

class CarbonApplication {
    private let app = NSApplication.shared
    private let appDelegate: CarbonAppDelegate
    private let assembler = CarbonAssembler()
    
    init(main: @escaping (CarbonDownloader) -> Void) {
        self.appDelegate = CarbonAppDelegate(main: main, provider: assembler)
        app.delegate = appDelegate
        app.run()
    }
    
    static func terminate() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
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
