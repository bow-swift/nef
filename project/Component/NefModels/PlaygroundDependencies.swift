//  Copyright © 2020 The nef Authors.

import Foundation

public enum PlaygroundDependencies {
    case bow(Bow)
    case podfile(URL)
    case cartfile(URL)
    
    public enum Bow {
        case version(String = "")
        case branch(String)
        case tag(String)
        case commit(String)
    }
}
