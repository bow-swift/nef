//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

private let console = Console(script: "nefc", description: "")

@discardableResult
func main() -> Either<CLIKit.Console.Error, Void> {
    let content =   """
                    import Foundation
                    
                    var str = "Hello, playground"

                    extension String {
                        var `extension`: String {
                            let ext = components(separatedBy: ".").last ?? ""
                            return ext == self ? "" : ext
                        }
                    }

                    /*:
                     ## Hola
                     */

                    import Bow
                    // nef:begin:hidden
                    // esto va oculto
                    // nef:end

                    import BowEffects

                    var hola = [1]
                    hola = Array(hola[1...])

                    "hola.jpg".extension
                    "hola".extension
                    """
    
    return nef.Compiler.compile(content: content)
                       .provide(console)^
                       .mapError { _ in .render() }
                       .foldM({ _ in console.exit(failure: "rendering Xcode Playgrounds from '<input>'") },
                              { _ in console.exit(success: "rendered Xcode Playgrounds in '<outpu>'")    })
                       .unsafeRunSyncEither()
}

// #: - MAIN <launcher>
main()
