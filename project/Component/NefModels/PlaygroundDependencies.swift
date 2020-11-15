//  Copyright © 2020 The nef Authors.

import Foundation

/// Models the supported `nef Playground` dependencies.
public enum PlaygroundDependencies {
    /// Describes the bow dependencies.
    case bow(Bow)
    
    /// Project uses Swift Packages Manager.
    case spm
    
    /// Project uses CocoaPods.
    case cocoapods(podfile: URL?)
    
    /// Project uses Carthage.
    case carthage(cartfile: URL?)
    
    /// Models the `Bow` dependencies.
    public enum Bow {
        /// Represents the version number `x.y.z`
        case version(String = "")
        
        /// Represents the branch of the repo.
        case branch(String)
        
        /// Represents the tag of the repo.
        case tag(String)
        
        /// Represents the commit hash of the repo.
        case commit(String)
    }
}
