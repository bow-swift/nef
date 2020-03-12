//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct PlaygroundCommand: ConsoleCommand {
    public static var commandName: String = "nef-playground"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Build a playground compatible with external frameworks")

    public init() {}
    
    @ArgumentParser.Option(help: "Path where nef Playground will be generated")
    var output: String

    @ArgumentParser.Option(default: "BowPlayground", help: ArgumentHelp("Specify the name for the nef Playground", valueName: "playground name"))
    var name: String

    @ArgumentParser.Option(default: .ios, help: "set the target to `ios` or `macos`")
    var platform: Platform
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Xcode Playground to be transformed into nef Playground")
    var playground: String
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Path to Podfile with your own dependencies")
    var podfile: String
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Path to Cartfile with your own dependencies")
    var cartfile: String
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Specify the version of Bow")
    var bowVersion: String
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Specify the branch of Bow")
    var bowBranch: String
    
    @ArgumentParser.Option(default: ArgumentEmpty, help: "Specify the commit of Bow")
    var bowCommit: String
    
    var outputURL: URL { URL(fileURLWithPath: output.trimmingEmptyCharacters.expandingTildeInPath) }
    var playgroundURL: URL? { playground == ArgumentEmpty ? nil : URL(fileURLWithPath: playground.trimmingEmptyCharacters.expandingTildeInPath) }
    var podfileURL: URL  { URL(fileURLWithPath: podfile.trimmingEmptyCharacters.expandingTildeInPath) }
    var cartfileURL: URL { URL(fileURLWithPath: cartfile.trimmingEmptyCharacters.expandingTildeInPath) }
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { (name, output, platform, playground, dependencies) in
                playground.toOption()
                    .fold({        self.nefPlayground(name: name, output: output, platform: platform, dependencies: dependencies).provide(Console.default)                       },
                          { url in self.nefPlayground(xcodePlayground: url, name: name, output: output, platform: platform, dependencies: dependencies).provide(Console.default) })
            }^
    }
    
    // MARK: private methods
    private func nefPlayground<A>(xcodePlayground: URL, name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<CLIKit.Console, CLIKit.Console.Error, A> {
        EnvIO { console in
            nef.Playground.nef(xcodePlayground: xcodePlayground, name: name, output: output, platform: platform, dependencies: dependencies)
                          .provide(console)^
                          .mapError { _ in .render() }
                          .foldM({ e in console.exit(failure: "building nef Playground from Xcode Playground '\(xcodePlayground.path)'. \(e)") },
                                 { _ in console.exit(success: "nef Playground created successfully in '\(output.path)'")                       })^
        }
    }

    private func nefPlayground<A>(name: String, output: URL, platform: Platform, dependencies: PlaygroundDependencies) -> EnvIO<CLIKit.Console, CLIKit.Console.Error, A> {
        EnvIO { console in
            nef.Playground.nef(name: name, output: output, platform: platform, dependencies: dependencies)
                          .provide(console)^
                          .mapError { _ in .render() }
                          .foldM({ e in console.exit(failure: "building nef Playground in '\(output.path)'. \(e)")            },
                                 { output in console.exit(success: "nef Playground created successfully in '\(output.path)'") })^
        }
    }
    
    private func arguments(parsableCommand: PlaygroundCommand) -> IO<CLIKit.Console.Error, (name: String, output: URL, platform: Platform, playground: URL?, dependencies: PlaygroundDependencies)> {
        let dependencies: PlaygroundDependencies
        if parsableCommand.bowVersion != ArgumentEmpty {
            dependencies = .bow(.version(parsableCommand.bowVersion))
        } else if parsableCommand.bowBranch != ArgumentEmpty {
            dependencies = .bow(.branch(parsableCommand.bowBranch))
        } else if parsableCommand.bowCommit != ArgumentEmpty {
            dependencies = .bow(.commit(parsableCommand.bowCommit))
        } else if parsableCommand.podfile != ArgumentEmpty {
            dependencies = .podfile(parsableCommand.podfileURL)
        } else if parsableCommand.cartfile != ArgumentEmpty {
            dependencies = .cartfile(parsableCommand.cartfileURL)
        } else {
            dependencies = .bow(.version(""))
        }
        
        return IO.pure((name: parsableCommand.name,
                        output: parsableCommand.outputURL,
                        platform: parsableCommand.platform,
                        playground: parsableCommand.playgroundURL,
                        dependencies: dependencies))^
    }
}
