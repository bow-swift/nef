//  Copyright © 2019 The nef Authors.

import AppKit

class CarbonAppDelegate: NSObject, NSApplicationDelegate {
    private let main: () -> Void
    private let queue: DispatchQueue
    
    init(main: @escaping () -> Void) {
        self.main = main
        self.queue = DispatchQueue(label: String(describing: CarbonAppDelegate.self), qos: .userInitiated)
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        queue.async {
            self.main()
        }
    }
}
