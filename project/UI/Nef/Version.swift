//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects
import AppKit

public struct VersionCommand: ParsableCommand {
    public static var commandName: String = "version"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Get the build version number")
    
    public init() {}
    
    
    public func run() throws {
        try run().provide(ArgumentConsole())^.unsafeRunSync()
    }
    
    func run() -> EnvIO<CLIKit.Console, Never, Void> {
        let code =  """
                    import nef
                    let library = 'nef library is super cool!'
                    """
        
        let style = CarbonStyle(background: .bow,
                                theme: .dracula,
                                size: .x1,
                                fontType: .firaCode,
                                lineNumbers: true, watermark: true)
        
        let io: EnvIO<nef.Console, nef.Error, Data> = nef.Carbon.render(code: code, style: style)
        
        return EnvIO { (console: CLIKit.Console) in
            func extractImage(from data: Data) -> IO<nef.Error, NSImage> {
                guard let image = NSImage(data: data) else { return IO.raiseError(.carbon(info: "invalid image"))^ }
                return IO.pure(image)^
            }
            
            let imageIO: IO<nef.Error, NSImage> = io.provide(console).flatMap(extractImage)^
            
            return nef.Version.info()
                .flatMap { version in console.print(message: "Build version number: \(version)", terminator: " ") }
                .flatMap { _ in console.printStatus(success: true) }
        }^
    }
}
