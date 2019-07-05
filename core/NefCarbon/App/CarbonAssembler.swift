//  Copyright © 2019 The nef Authors.

import AppKit
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
    
    public func resolveWindow() -> NSWindow {
        return NSWindow(contentRect: CarbonScreen.bounds,
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
