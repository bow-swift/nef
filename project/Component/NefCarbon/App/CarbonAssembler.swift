//  Copyright © 2019 The nef Authors.

import AppKit
import NefCore

class CarbonAssembler: CarbonProvider, CarbonAppDelegateAssembler {}

// MARK: Assembler
protocol CarbonAppDelegateAssembler {
    func resolveWindow() -> NSWindow
    func resolveCarbonView(frame: NSRect) -> CarbonView
}

protocol CarbonProvider {
    func resolveCarbonDownloader(view: CarbonView) -> CarbonDownloader
    func resolveCarbonDownloader() -> CarbonDownloader
}

// MARK: dependency injection
extension CarbonAssembler {
    func resolveCarbonDownloader(view: CarbonView) -> CarbonDownloader {
        CarbonSyncDownloader(view: view)
    }
    
    func resolveCarbonView(frame: NSRect) -> CarbonView {
        CarbonWKWebView(frame: frame)
    }
    
    func resolveWindow() -> NSWindow {
        NSWindow(contentRect: CarbonScreen.bounds,
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: true,
                screen: CarbonScreen())
    }
    
    func resolveCarbonDownloader() -> CarbonDownloader {
        let window = resolveWindow()
        let view = window.contentView!
        let carbonView = resolveCarbonView(frame: window.frame)
        view.addSubview(carbonView) // retain window
        return resolveCarbonDownloader(view: carbonView)
    }
}

// MARK: private classes
private class CarbonScreen: NSScreen {
    static let bounds = NSRect(x: 0, y: 0, width: 5000, height: 15000)
    
    override var frame: NSRect { return CarbonScreen.bounds }
    override var visibleFrame: NSRect { return CarbonScreen.bounds }
}
