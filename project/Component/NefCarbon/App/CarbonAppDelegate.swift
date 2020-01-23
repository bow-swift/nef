//  Copyright © 2019 The nef Authors.

import AppKit
import NefCore

class CarbonAppDelegate: NSObject, NSApplicationDelegate {
    private let main: (CarbonDownloader) -> Void
    private let carbonView: CarbonView
    private let downloader: CarbonDownloader
    private let queue: DispatchQueue
    private let window: NSWindow
    
    init(assembler: CarbonAppDelegateAssembler, provider: CarbonProvider, main: @escaping (CarbonDownloader) -> Void) {
        self.main = main
        self.window = assembler.resolveWindow()
        self.carbonView = assembler.resolveCarbonView(frame: window.frame)
        self.downloader = provider.resolveCarbonDownloader(view: carbonView)
        self.queue = DispatchQueue(label: String(describing: CarbonAppDelegate.self), qos: .userInitiated)
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window.contentView?.addSubview(carbonView)
        window.makeKey()
        
        queue.async { // the whole CLI will run in our thread
            self.main(self.downloader)
        }
    }
}

// MARK: Assembler
protocol CarbonAppDelegateAssembler {
    func resolveWindow() -> NSWindow
    func resolveCarbonView(frame: NSRect) -> CarbonView
}

protocol CarbonProvider {
    func resolveCarbonDownloader(view: CarbonView) -> CarbonDownloader
    func resolveCarbonDownloader() -> CarbonDownloader
}
