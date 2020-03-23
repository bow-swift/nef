//  Copyright © 2020 The nef Authors.

import AppKit

/// Describes a Carbon loading view.
public protocol CarbonLoadingView: NSView {
    
    /// Shows the loading view.
    func show()
    
    /// Hides the loading view.
    func hide()
}

/// Describes a Carbon view.
public protocol CarbonView: NSView {
    
    /// Associated Carbon loading view.
    var loadingView: CarbonLoadingView? { get set }
    
    /// Need to reload the Carbon style.
    func update(state: CarbonStyle)
}
