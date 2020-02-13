//  Copyright © 2019 The nef Authors.

import AppKit
import NefCore

class CarbonAssembler {
    
    func resolveCarbonDownloader() -> CarbonDownloader {
        let window = resolveWindow()
        let view = window.contentView!
        let carbonView = CarbonWKWebView(frame: window.frame)
        view.addSubview(carbonView) // retain window
        return CarbonSyncDownloader(view: carbonView)
    }

    private func resolveWindow() -> NSWindow {
        NSWindow(contentRect: CarbonScreen.bounds,
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: true,
                screen: CarbonScreen())
    }
}

// MARK: private classes
private class CarbonScreen: NSScreen {
    static let bounds = NSRect(x: 0, y: 0, width: 5000, height: 15000)
    
    override var frame: NSRect { return CarbonScreen.bounds }
    override var visibleFrame: NSRect { return CarbonScreen.bounds }
}
