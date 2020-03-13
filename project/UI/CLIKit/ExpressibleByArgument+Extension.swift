//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import NefModels

extension Platform: ExpressibleByArgument {}
extension CarbonStyle.Size: ExpressibleByArgument {}
extension CarbonStyle.Theme: ExpressibleByArgument {}
extension CarbonStyle.Font: ExpressibleByArgument {}

// MARK: - Models
public struct ArgumentPath: Codable, ExpressibleByArgument {
    public let url: URL
    public let path: String
    
    public init(argument: String) {
        self.path = argument.trimmingEmptyCharacters.expandingTildeInPath
        self.url = URL(fileURLWithPath: self.path)
    }
}
