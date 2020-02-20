//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum PlaygroundCommand: String {
    case name
    case output
    case playground
    case platform
    
    case bowVersion = "bow-version"
    case bowBranch  = "bow-branch"
    case bowCommit  = "bow-commit"
    case podfile
    case cartfile
}

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

@discardableResult
public func playground() -> Either<CLIKit.Console.Error, Void> {
    let console = Console(script: "nef-playground",
                          description: "Build a nef Playground compatible with 3rd-party libraries",
                          arguments: .init(name: PlaygroundCommand.output.rawValue, placeholder: "path-to-output",  description: "path where nef Playground will be generated"),
                                     .init(name: PlaygroundCommand.name.rawValue, placeholder: "playground-name", description: "specify the name for the nef Playground", default: "BowPlayground"),
                                     .init(name: PlaygroundCommand.platform.rawValue, placeholder: "", description: "set the target to `ios` or `macos`", default: "ios"),
                                     .init(name: PlaygroundCommand.playground.rawValue, placeholder: "path-to-playground", description: "Xcode Playground to be transformed into nef Playground", default: " "),
                                     .init(name: PlaygroundCommand.bowVersion.rawValue, placeholder: "", description: "specify the version of Bow", default: " "),
                                     .init(name: PlaygroundCommand.bowBranch.rawValue,  placeholder: "", description: "specify the branch of Bow", default: " "),
                                     .init(name: PlaygroundCommand.bowCommit.rawValue,  placeholder: "", description: "specify the commit of Bow", default: " "),
                                     .init(name: PlaygroundCommand.podfile.rawValue,    placeholder: "", description: "path to Podfile with your own dependencies", default: " "),
                                     .init(name: PlaygroundCommand.cartfile.rawValue,   placeholder: "", description: "path to Cartfile with your own dependencies", default: " "))


    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, (name: String, output: URL, platform: Platform, playground: URL?, dependencies: PlaygroundDependencies)> {
        console.input().flatMap { args in
            guard let outputPath = args[PlaygroundCommand.output.rawValue]?.trimmingEmptyCharacters.expandingTildeInPath,
                  let name = args[PlaygroundCommand.name.rawValue]?.trimmingEmptyCharacters,
                  let platform = Platform(platform: args[PlaygroundCommand.platform.rawValue]?.trimmingEmptyCharacters ?? ""),
                  let playgroundPath = args[PlaygroundCommand.playground.rawValue]?.trimmingEmptyCharacters,
                  let bowVersion = args[PlaygroundCommand.bowVersion.rawValue]?.trimmingEmptyCharacters,
                  let bowBranch = args[PlaygroundCommand.bowBranch.rawValue]?.trimmingEmptyCharacters,
                  let bowCommit = args[PlaygroundCommand.bowCommit.rawValue]?.trimmingEmptyCharacters,
                  let podfile = args[PlaygroundCommand.podfile.rawValue]?.trimmingEmptyCharacters,
                  let cartfile = args[PlaygroundCommand.cartfile.rawValue]?.trimmingEmptyCharacters else {
                    return IO.raiseError(.arguments)
            }
            
            let output = URL(fileURLWithPath: outputPath, isDirectory: true)
            let playground = playgroundPath.isEmpty ? nil : URL(fileURLWithPath: playgroundPath)
            
            let dependencies: PlaygroundDependencies
            if !bowVersion.isEmpty     { dependencies = .bow(.version(bowVersion)) }
            else if !bowBranch.isEmpty { dependencies = .bow(.branch(bowBranch)) }
            else if !bowCommit.isEmpty { dependencies = .bow(.commit(bowCommit)) }
            else if !podfile.isEmpty   { dependencies = .podfile(URL(fileURLWithPath: podfile)) }
            else if !cartfile.isEmpty  { dependencies = .cartfile(URL(fileURLWithPath: cartfile)) }
            else { dependencies = .bow(.version("")) }
            
            return IO.pure((name: name,
                            output: output,
                            platform: platform,
                            playground: playground,
                            dependencies: dependencies))
        }^
    }

    return arguments(console: console)
        .flatMap { (name, output, platform, playground, dependencies) in
            playground.toOption()
                .fold({        nefPlayground(name: name, output: output, platform: platform, dependencies: dependencies).provide(console)                       },
                      { url in nefPlayground(xcodePlayground: url, name: name, output: output, platform: platform, dependencies: dependencies).provide(console) })
        }^
        .reportStatus(in: console)
        .foldM({ e in console.exit(failure: "\(e)")        },
               { success in console.exit(success: success) })
        .unsafeRunSyncEither()
}
