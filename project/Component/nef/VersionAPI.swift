//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

/// Describes the API for `Version`
public protocol VersionAPI {
    /// Gets nef build version number.
    ///
    /// - Returns: An IO that never produce errors and returns the build version number.
    static func info() -> UIO<String>
}

/// Instance of the Version API
public enum Version: VersionAPI {
    public static func info() -> UIO<String> {
        IO.pure(BuildConfiguration.buildVersion)^
    }
}
