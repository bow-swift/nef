//  Copyright © 2020 The nef Authors.

import Foundation
import ArgumentParser
import NefCarbon
import Bow
import BowEffects

public struct CommandLineTool<T: ParsableCommand> {
    public static func main() {
        _ = CarbonApplication { T.main() }
    }
}

public extension ParsableCommand {
    static var console: Console { .default }
}
