//  Copyright © 2020 The nef Authors.

import Foundation

/// Models the supported `nef Playground` dependencies.
///
/// - bow: describes the bow dependencies.
/// - podfile: describes the CocoaPods dependencies.
/// - cartfile: describes the Carthage dependencies.
public enum PlaygroundDependencies {
    case bow(Bow)
    case podfile(URL)
    case cartfile(URL)
    
    /// Models the `Bow` dependencies.
    ///
    /// - version: represents the version number `x.y.z`
    /// - branch: represents the branch of the repo.
    /// - tag: represents the tag of the repo.
    /// - commit: represents the commit hash of the repo.
    public enum Bow {
        case version(String = "")
        case branch(String)
        case tag(String)
        case commit(String)
    }
}
