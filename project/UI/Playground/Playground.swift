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
    
    @ArgumentParser.Option(help: ArgumentHelp("Specify the name for the nef Playground", valueName: "playground name"))
    private var name: String = "BowPlayground"
    
    @ArgumentParser.Option(help: ArgumentHelp("Path where nef Playground will be generated", valueName: "path"))
    private var output: ArgumentPath = .init(argument: ".")

    @ArgumentParser.Option(help: "Set the target to `ios` or `macos`")
    private var platform: Platform = .ios
    
    @ArgumentParser.Option(help: ArgumentHelp("Xcode Playground to be transformed into nef Playground", valueName: "Xcode Playground"))
    private var playground: ArgumentPath?
    
    @ArgumentParser.Flag(help: "Use Swift Package Manager to resolve dependencies")
    private var spm: Bool = false
    
    @ArgumentParser.Flag(help: "Use CocoaPods to resolve dependencies")
    private var cocoapods: Bool = false
    
    @ArgumentParser.Option(name: .customLong("custom-podfile"), help: ArgumentHelp("Path to your podfile with own dependencies", valueName: "path"))
    private var podfile: ArgumentPath?
    
    @ArgumentParser.Flag(help: "Use Carthage to resolve dependencies")
    private var carthage: Bool = false
    
    @ArgumentParser.Option(name: .customLong("custom-cartfile"), help: ArgumentHelp("Path to your cartfile with own dependencies", valueName: "path"))
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
    
    func run<D: ProgressReport & OutcomeReport>() -> EnvIO<D, nef.Error, Void> {
        let dependencies = EnvIO<D, nef.Error, PlaygroundDependencies>.var()
        let nefPlayground = EnvIO<D, nef.Error, Void>.var()
        
        return binding(
             dependencies <- self.dependencies(xcodePlayground: playground?.url),
            nefPlayground <- self.run(xcodePlayground: playground?.url,
                                      name: name,
                                      output: output.url,
                                      platform: platform,
                                      dependencies: dependencies.get),
        yield: nefPlayground.get)^
    }
    
    func run<D: ProgressReport & OutcomeReport>(
        xcodePlayground: URL?,
        name: String,
        output: URL,
        platform: Platform,
        dependencies: PlaygroundDependencies
    ) -> EnvIO<D, nef.Error, Void> {
        
        xcodePlayground.toOption().fold(
            {
                self.nefPlayground(name: name,
                                   output: output,
                                   platform: platform,
                                   dependencies: dependencies)
            },
            { arg in
                self.nefPlayground(xcodePlayground: arg,
                                   name: name,
                                   output: output,
                                   platform: platform,
                                   dependencies: dependencies)
            })
    }
    
    // MARK: attributes
    private var dependencies: Result<PlaygroundDependencies, PlaygroundDependenciesError> {
        guard numberOfDependencies <= 1 else { return .failure(.invalid) }
        
        if let version = bowVersion {
            return .success(.bow(.version(version)))
        } else if let branch = bowBranch {
            return .success(.bow(.branch(branch)))
        } else if let commit = bowCommit {
            return .success(.bow(.commit(commit)))
        } else if spm {
            return .success(.spm)
        } else if cocoapods  {
            return .success(.cocoapods(podfile: podfile?.url))
        } else if carthage  {
            return .success(.carthage(cartfile: cartfile?.url))
        } else {
            return .failure(.notFound)
        }
    }
    
    private var numberOfDependencies: Int {
        [
            bowVersion,
            bowBranch,
            bowCommit,
            spm ? "true" : nil,
            cocoapods ? "true" : nil,
            carthage ? "true" : nil
        ].compactMap { $0 }.count
    }
    
    // MARK: private methods
    private func dependencies<D>(xcodePlayground: URL?) -> EnvIO<D, nef.Error, PlaygroundDependencies> {
        EnvIO.invokeResult { _ in
            self.dependencies.flatMapError { error in
                guard error != .invalid else { return .failure(.playground(info: "Invalid configuration for dependency manager")) }
                
                return xcodePlayground == nil
                    ? .success(.bow(.version()))
                    : .success(.spm)
            }
        }
    }
    
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
