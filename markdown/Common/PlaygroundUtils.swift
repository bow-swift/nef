//  Copyright © 2019 The nef Authors.

import Foundation

struct PlaygroundUtils {

    /// Get the filename from a playground's page
    ///
    /// - Parameter page: the paht to playground's page
    /// - Returns: the filename
    static func playgroundName(fromPage page: String) -> String {
        guard !page.isEmpty else { return "page-default" }

        let filenameComponentes = page.components(separatedBy: "/")
        let filenameWithExtension = filenameComponentes[filenameComponentes.count-1]
        let filename = filenameWithExtension.components(separatedBy: ".").dropLast().joined(separator: ".")

        return filename
    }
}
