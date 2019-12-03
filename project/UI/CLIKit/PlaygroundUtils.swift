//  Copyright © 2019 The nef Authors.

import Foundation
import nef

public struct PlaygroundUtils {

    private static let defaultName = "page-default"
    
    /// Get the filename from a playground's page
    ///
    /// - Parameter page: the paht to playground's page
    /// - Returns: the filename
    public static func playgroundName(fromPage page: String) -> String {
        guard !page.isEmpty else { return PlaygroundUtils.defaultName }

        return page.pathComponents
                   .first(where: { $0.contains(".xcplaygroundpage") })?
                   .removeExtension
               ?? PlaygroundUtils.defaultName
    }
}
