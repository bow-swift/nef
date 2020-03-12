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
    public var url: URL { URL(fileURLWithPath: path) }
    public var path: String { _path.trimmingEmptyCharacters.expandingTildeInPath }
    
    private let _path: String
    
    public init(argument: String) {
        self._path = argument
    }
}
