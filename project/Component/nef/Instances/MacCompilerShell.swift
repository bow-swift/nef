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
            let result = run("pod", args: cached ? ["install", "--project-directory=\(project.path)"]
                                                 : ["install", "--repo-update", "--project-directory=\(project.path)"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.notFound(command: "pod", information: "error: \(result.stderr) - output: \(result.stdout) install cocoapods using `gem install cocoapods`")
            }
            
            return ()
        }
    }
    
    func carthage(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> {
        IO.invoke {
            let result = run("carthage", args: cached ? ["bootstrap", "--cache-builds", "--platform", platform == .ios ? "ios" : "osx", "--project-directory", project.path]
                                                      : ["bootstrap", "--platform", platform == .ios ? "ios" : "osx", "--project-directory", project.path])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.notFound(command: "carthage", information: "error: \(result.stderr) - output: \(result.stdout) install carthage using `brew install carthage`")
            }
            
            return ()
        }
    }
    
    func build(xcworkspace: URL, scheme: String, platform: Platform, derivedData: URL, log: URL) -> IO<CompilerShellError, Void> {
        IO.invoke {
            let result = run("/usr/bin/xcodebuild", args: ["-workspace", xcworkspace.path,
                                                           "-sdk", platform.sdk,
                                                           "-scheme", scheme,
                                                           "-derivedDataPath", derivedData.path,
                                                           "-configuration", "Debug"]) { settings in settings.execution = .log(file: log.path) }
            guard result.exitStatus == 0,
                  let logContent = try? String(contentsOfFile: log.path),
                  logContent.contains("BUILD SUCCEEDED") else {
                throw CompilerShellError.failed(command: "xcodebuild", information: result.stderr)
            }
            
            return ()
        }
    }
}
