//  Copyright © 2019 The nef Authors.

import Foundation

public struct PlaygroundUtils {

    private static let defaultName = "page-default"
    
    /// Get the filename from a playground's page
    ///
    /// - Parameter page: the paht to playground's page
    /// - Returns: the filename
    public static func playgroundName(fromPage page: String) -> String {
        let filenameComponentes = page.components(separatedBy: "/")
        let filenameWithExtension = filenameComponentes.first(where: { $0.contains("xcplaygroundpage") })
        return filenameWithExtension?.replacingOccurrences(of: ".xcplaygroundpage", with: "") ?? PlaygroundUtils.defaultName
    }
}
