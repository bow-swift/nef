//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

struct PlaygroundArguments {
    let name: String
    let output: URL
    let platform: Platform
    let playground: URL?
    let dependencies: PlaygroundDependencies
}

public struct PlaygroundCommand: ConsoleCommand {
    public static var commandName: String = "nef-playground"
    public static var configuration = CommandConfiguration(commandName: commandName,
                                                           abstract: "Build a playground compatible with external frameworks")

    public init() {}
    
    @ArgumentParser.Option(help: "Path where nef Playground will be generated")
    private var output: ArgumentPath

    @ArgumentParser.Option(default: "BowPlayground", help: ArgumentHelp("Specify the name for the nef Playground", valueName: "playground name"))
    private var name: String

    @ArgumentParser.Option(default: .ios, help: "set the target to `ios` or `macos`")
    private var platform: Platform
    
    @ArgumentParser.Option(help: "Xcode Playground to be transformed into nef Playground")
    private var playground: ArgumentPath?
    
    @ArgumentParser.Option(help: "Path to Podfile with your own dependencies")
    private var podfile: ArgumentPath?
    
    @ArgumentParser.Option(help: "Path to Cartfile with your own dependencies")
    private var cartfile: ArgumentPath?
    
    @ArgumentParser.Option(help: "Specify the version of Bow")
    private var bowVersion: String?
    
    @ArgumentParser.Option(help: "Specify the branch of Bow")
    var bowBranch: String?
    
    @ArgumentParser.Option(help: "Specify the commit of Bow")
    var bowCommit: String?
    
    
    public func main() -> IO<CLIKit.Console.Error, Void> {
        arguments(parsableCommand: self)
            .flatMap { args in
                args.playground.toOption()
                    .fold({        self.nefPlayground(name: args.name, output: args.output, platform: args.platform, dependencies: args.dependencies).provide(Console.default)                       },
                          { url in self.nefPlayground(xcodePlayground: url, name: args.name, output: args.output, platform: args.platform, dependencies: args.dependencies).provide(Console.default) })
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
    
    private func arguments(parsableCommand: PlaygroundCommand) -> IO<CLIKit.Console.Error, PlaygroundArguments> {
        let dependencies: PlaygroundDependencies
        if let version = parsableCommand.bowVersion {
            dependencies = .bow(.version(version))
        } else if let branch = parsableCommand.bowBranch {
            dependencies = .bow(.branch(branch))
        } else if let commit = parsableCommand.bowCommit {
            dependencies = .bow(.commit(commit))
        } else if let podfileURL = parsableCommand.podfile?.url {
            dependencies = .podfile(podfileURL)
        } else if let cartfileURL = parsableCommand.cartfile?.url {
            dependencies = .cartfile(cartfileURL)
        } else {
            dependencies = .bow(.version(""))
        }
        
        return IO.pure(.init(name: parsableCommand.name,
                             output: parsableCommand.output.url,
                             platform: parsableCommand.platform,
                             playground: parsableCommand.playground?.url,
                             dependencies: dependencies))^
    }
}
