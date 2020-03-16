//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import NefModels

extension Platform: ExpressibleByArgument {}
extension CarbonStyle.Size: ExpressibleByArgument {}
extension CarbonStyle.Theme: ExpressibleByArgument {}
extension CarbonStyle.Font: ExpressibleByArgument {}

// MARK: - Models
public struct ArgumentPath: Codable, ExpressibleByArgument, CustomStringConvertible {
    public let url: URL
    public let path: String
    public let description: String
    
    public init(argument: String) {
        self.description = argument
        self.path = argument.trimmingEmptyCharacters.expandingTildeInPath
        self.url = URL(fileURLWithPath: self.path)
    }
}
