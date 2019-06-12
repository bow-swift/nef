//  Copyright © 2019 The nef Authors.

import Foundation

struct PlaygroundUtils {

    private static let defaultName = "page-default"
    
    /// Get the filename from a playground's page
    ///
    /// - Parameter page: the paht to playground's page
    /// - Returns: the filename
    static func playgroundName(fromPage page: String) -> String {
        guard !page.isEmpty else { return PlaygroundUtils.defaultName }

        let filenameComponentes = page.components(separatedBy: "/")
        let filenameWithExtension = filenameComponentes.first(where: { $0.contains("xcplaygroundpage") })
        return filenameWithExtension?.components(separatedBy: ".").first ?? PlaygroundUtils.defaultName
    }
}
