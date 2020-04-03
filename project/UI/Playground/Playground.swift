//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import ArgumentParser
import nef
import Bow
import BowEffects

public struct PlaygroundCommand: ParsableCommand {
    public static var commandName: String = "nef-playground"
    public static var configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Build a playground compatible with external frameworks")

    public init() {}
    
    @ArgumentParser.Option(default: .init(argument: "."), help: ArgumentHelp("Path where nef Playground will be generated", valueName: "path"))
    private var output: ArgumentPath

    @ArgumentParser.Option(default: "BowPlayground", help: ArgumentHelp("Specify the name for the nef Playground", valueName: "playground name"))
    private var name: String

    @ArgumentParser.Option(default: .ios, help: "set the target to `ios` or `macos`")
    private var platform: Platform
    
    @ArgumentParser.Option(help: ArgumentHelp("Xcode Playground to be transformed into nef Playground", valueName: "Xcode Playground"))
    private var playground: ArgumentPath?
    
    @ArgumentParser.Option(help: "Path to Podfile with your own dependencies")
    private var podfile: ArgumentPath?
    
    @ArgumentParser.Option(help: "Path to Cartfile with your own dependencies")
    private var cartfile: ArgumentPath?
    
    @ArgumentParser.Option(help: ArgumentHelp("Specify the version of Bow", valueName: "x.y.z"))
    private var bowVersion: String?
    
    @ArgumentParser.Option(help: ArgumentHelp("Specify the branch of Bow", valueName: "branch name"))
    var bowBranch: String?
    
    @ArgumentParser.Option(help: ArgumentHelp("Specify the commit hash of Bow", valueName: "commit hash"))
    var bowCommit: String?
    
    public func run() throws {
        try run().provide(ConsoleReport())^.unsafeRunSync()
    }
    
    func run<D: ProgressReport & OutcomeReport>()
        -> EnvIO<D, nef.Error, Void> {
        playground.toOption()
            .fold(
                { self.nefPlayground(
                    name: self.name,
                    output: self.output.url,
                    platform: self.platform,
                    dependencies: self.dependencies)
                },
                { arg in self.nefPlayground(
                    xcodePlayground: arg.url,
                    name: self.name,
                    output: self.output.url,
                    platform: self.platform,
                    dependencies: self.dependencies)
                })
    }
    
    // MARK: attributes
    private var dependencies: PlaygroundDependencies {
        let dependencies: PlaygroundDependencies
        if let version = bowVersion {
            dependencies = .bow(.version(version))
        } else if let branch = bowBranch {
            dependencies = .bow(.branch(branch))
        } else if let commit = bowCommit {
            dependencies = .bow(.commit(commit))
        } else if let podfileURL = podfile?.url {
            dependencies = .podfile(podfileURL)
        } else if let cartfileURL = cartfile?.url {
            dependencies = .cartfile(cartfileURL)
        } else {
            dependencies = .bow(.version(""))
        }
        
        return dependencies
    }
    
    // MARK: private methods
    private func nefPlayground<D: ProgressReport & OutcomeReport>(
        xcodePlayground: URL,
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<D, nef.Error, Void> {
        
        nef.Playground.nef(xcodePlayground: xcodePlayground, name: name, output: output, platform: platform, dependencies: dependencies)
            .outcomeScope()
            .reportOutcome(
                success: { output in
                    "nef Playground created successfully in '\(output.path)'"
                },
                failure: { _ in
                    "building nef Playground from Xcode Playground '\(xcodePlayground.path)'"
                })
            .finish()
    }
    
    private func nefPlayground<D: ProgressReport & OutcomeReport>(
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<D, nef.Error, Void> {
        
        nef.Playground.nef(name: name, output: output, platform: platform, dependencies: dependencies)
            .outcomeScope()
            .reportOutcome(
                success: { output in
                    "nef Playground created successfully in '\(output.path)'"
                },
                failure: { _ in
                    "building nef Playground in '\(output.path)'"
                })
            .finish()
    }
}
