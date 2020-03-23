//  Copyright © 2020 The nef Authors.

import AppKit

/// Describes a Carbon loading view.
public protocol CarbonLoadingView: NSView {
    
    /// Loading view should change its state to show.
    func show()
    
    /// Loading view should change its state to hidden.
    func hide()
}

/// Describes a Carbon view.
public protocol CarbonView: NSView {
    
    /// Associated Carbon loading view.
    var loadingView: CarbonLoadingView? { get set }
    
    /// Need to reload the Carbon style.
    func update(state: CarbonStyle)
}
