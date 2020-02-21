//  Copyright © 2020 The nef Authors.

import Foundation
import CLIKit
import nef
import Bow
import BowEffects

enum NefCommand: String, CaseIterable {
    case compile
    case clean
    case playground
    case ipad
    case markdown
    case jekyll
    case carbon
}


func step(partial: UInt, duration: DispatchTimeInterval = .seconds(1)) -> Step {
    Step(total: 3, partial: partial, duration: duration)
}

@discardableResult
public func main() -> Either<CLIKit.Console.Error, Void> {

    func arguments(console: CLIKit.Console) -> IO<CLIKit.Console.Error, NefCommand> {
        console.input(help: false).flatMap { args in
            guard let action = NefCommand.allCases.first(where: { command in args[command.rawValue] == "true" }) else { return IO.raiseError(.help) }
            return IO.pure(action)
        }^
    }
    
    func readAction(console: CLIKit.Console) -> IO<CLIKit.Console.Error, NefCommand> {
        let action = IO<CLIKit.Console.Error, NefCommand>.var()
        
        return binding(
            action <- arguments(console: console),
                   |<-console.printStep(step: step(partial: 1), information: "Read the command "+"\(action.get)".bold),
        yield: action.get)^.reportStatus(in: console)
    }
    
    func unsafeRunSyncCommand(action: NefCommand) -> Either<CLIKit.Console.Error, Void> {
        let script = "nef \(action.rawValue)"
        
        switch action {
            case .compile:    return compiler(script: script)
            case .clean:      fatalError()
            case .playground: return playground(script: script)
            case .ipad:       return playgroundBook(script: script)
            case .markdown:   return markdown(script: script)
            case .jekyll:     return jekyll(script: script)
            case .carbon:     return carbon(script: script)
        }
    }
    
    let console = Console(script: "nef",
                          description: "Commands",
                          arguments: .init(name: NefCommand.compile.rawValue,    placeholder: "", description: "Compile Xcode Playgrounds given a <path>", isFlag: true, default: "false"),
                                     .init(name: NefCommand.clean.rawValue,      placeholder: "", description: "Clean a generated nef project from a <path>", isFlag: true, default: "false"),
                                     .init(name: NefCommand.playground.rawValue, placeholder: "", description: "Build a playground compatible with external frameworks", isFlag: true, default: "false"),
                                     .init(name: NefCommand.ipad.rawValue,       placeholder: "", description: "Build a playground compatible with iPad and 3rd-party libraries", isFlag: true, default: "false"),
                                     .init(name: NefCommand.markdown.rawValue,   placeholder: "", description: "Render Markdown files for given Xcode Playgrounds", isFlag: true, default: "false"),
                                     .init(name: NefCommand.jekyll.rawValue,     placeholder: "", description: "Render Markdown files that can be consumed from Jekyll to generate a microsite", isFlag: true, default: "false"),
                                     .init(name: NefCommand.carbon.rawValue,     placeholder: "", description: "Export Carbon code snippets for given Xcode Playgrounds", isFlag: true, default: "false"))
    
    return readAction(console: console)
            .unsafeRunSyncEither()
            .flatMap(unsafeRunSyncCommand)^
}

// #: - MAIN <launcher>
main()
