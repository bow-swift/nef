//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefModels
import NefPlayground

import Bow
import BowEffects


public extension VersionAPI {
    
    static func info() -> UIO<String> {
        IO.pure(Configuration.buildVersion)^
    }
}

