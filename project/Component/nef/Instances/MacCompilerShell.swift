//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCompiler
import Swiftline
import Bow
import BowEffects


class MacCompilerShell: CompilerShell {
    
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> {
        IO.invoke {
            
//            let result1 = run("sudo gem", args:["update", "bundler"])
            let result = run("pod", args: cached ? ["install", "--repo-update", "--project-directory=\(project.path)"]
                                                 : ["install", "--project-directory=\(project.path)"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.notFound(command: "pod", information: "\(result.stderr). Install cocoapods using `gem install cocoapods`.")
            }
            
            
            return ()
        }
    }
    
    func carthage(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> {
        fatalError()
    }
}
