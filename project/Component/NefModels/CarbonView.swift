//  Copyright © 2020 The nef Authors.

import AppKit

public protocol CarbonLoadingView: NSView {
    func show()
    func hide()
}

public protocol CarbonView: NSView {
    var loadingView: CarbonLoadingView? { get set }
    func update(state: CarbonStyle)
}
