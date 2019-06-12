//  Copyright © 2019 The nef Authors.

import AppKit
import Markup

class CarbonAppDelegate: NSObject, NSApplicationDelegate {
    let main: (CarbonDownloader) -> Void
    let carbonWebView: CarbonWebView
    let downloader: CarbonDownloader
    
    let window = NSWindow(contentRect: CarbonScreen.bounds,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: true,
                          screen: CarbonScreen())
    
    init(main: @escaping (CarbonDownloader) -> Void, provider: CarbonProvider) {
        self.carbonWebView = CarbonWebView(frame: CarbonScreen.bounds)
        self.main = main
        self.downloader = provider.resolveCarbonDownloader(view: carbonWebView)
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window.contentView?.addSubview(carbonWebView)
        main(downloader)
    }
    
    // MARK: private classes
    private class CarbonScreen: NSScreen {
        static let bounds = NSRect(x: 0, y: 0, width: 3000, height: 5000)
        
        override var frame: NSRect { return CarbonScreen.bounds }
        override var visibleFrame: NSRect { return CarbonScreen.bounds }
    }
}
