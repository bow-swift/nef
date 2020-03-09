//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import NefModels

public let ArgumentEmpty = "-"

extension Platform: ExpressibleByArgument {}
extension CarbonStyle.Size: ExpressibleByArgument {}
extension CarbonStyle.Theme: ExpressibleByArgument {}
extension CarbonStyle.Font: ExpressibleByArgument {}
