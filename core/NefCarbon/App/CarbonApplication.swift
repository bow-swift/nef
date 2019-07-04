//  Copyright © 2019 The nef Authors.

import AppKit
import Markup

public class CarbonApplication {
    private static let app = NSApplication.shared
    private let appDelegate: CarbonAppDelegate
    private let assembler = CarbonAssembler()
    
    public init(main: @escaping (CarbonDownloader) -> Void) {
        appDelegate = CarbonAppDelegate(main: main, provider: assembler)
        CarbonApplication.app.delegate = appDelegate
        CarbonApplication.app.run()
    }
    
    static func terminate() {
        DispatchQueue.main.async {
            CarbonApplication.app.terminate(nil)
        }
    }
}

// MARK: Assembler
public protocol CarbonProvider {
    func resolveCarbonDownloader(view: CarbonView) -> CarbonDownloader
}
