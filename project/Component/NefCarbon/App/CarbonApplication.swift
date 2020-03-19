//  Copyright © 2019 The nef Authors.

import AppKit

public class CarbonApplication {
    private static let app = NSApplication.shared
    private let appDelegate: CarbonAppDelegate
    private let assembler = CarbonAssembler()
    
    public init(main: @escaping () -> Void) {
        appDelegate = CarbonAppDelegate(main: main)
        CarbonApplication.app.delegate = appDelegate
        CarbonApplication.app.run()
    }
    
    static public func terminate() {
        DispatchQueue.main.async {
            CarbonApplication.app.terminate(nil)
        }
    }
}
