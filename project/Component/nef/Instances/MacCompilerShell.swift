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
    
    func dependencies(platform: Platform) -> IO<CompilerShellError, URL> {
        IO.invoke {
            let result = run("/usr/bin/xcode-select", args: ["-p"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.failed(command: "xcode-select", information: result.stderr)
            }
            
            return URL(fileURLWithPath: "\(result.stdout)/Platforms/\(platform.framework).platform/Developer/Library/Frameworks")
        }
    }
    
    func compile(file: URL, sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL], output: URL, log: URL) -> IO<CompilerShellError, Void> {
        let target = IO<CompilerShellError, String>.var()
        
        return binding(
            target <- self.target(platform: platform),
                   |<-self.compile(file: file,
                                   sources: sources,
                                   platform: platform,
                                   target: target.get,
                                   frameworks: frameworks,
                                   linkers: linkers,
                                   output: output, log: log),
        yield: ())^
    }
    
    // MARK: private methods
    private func compile(file: URL, sources: [URL], platform: Platform, target: String, frameworks: [URL], linkers: [URL], output: URL, log: URL) -> IO<CompilerShellError, Void> {
        IO.invoke {
            let linkFrameworks = (frameworks + linkers).flatMap { fw in ["-F", fw.path] }
            let xlinkers = linkers.flatMap { linker in ["-Xlinker", linker.path] }
            let linkSwiftCore = platform == .ios ? ["-lswiftXCTest"] : ["-lswiftCore"]
            let sourcesPaths = sources.map { (source: URL) in source.path }
            
            let args = ["-k"]                                     // invalidate all existing cache entries
                        .append("-sdk").append(platform.sdk)      // find the tool for the given SDK name
                        .append("swiftc")                         // swift compiler
                        .append("-D").append("NOT_IN_PLAYGROUND") // allow use `import PlaygroundSupport` and utils outside Xcode Playgrounds
                        .append("-target").append(target)         // generate code for the given target
                        .appending(contentsOf: linkFrameworks)    // add directories to frameworks search path
                        .append("-Xlinker").append("-rpath")      // -Xlinker, specifies an option which should be passed to the linker
                        .appending(contentsOf: xlinkers)
                        .appending(contentsOf: linkSwiftCore)     // -l, specifies a library which should be linked against
                        .appending(contentsOf: sourcesPaths)      // sources to link against main.swift
                        .append(file.path)                        // main.swift - allow top level function (playground)
                        .append("-o").append(output.path.removeExtension)
            
            let result = run("/usr/bin/xcrun", args: args) { settings in settings.execution = .log(file: log.path) }
            
            guard result.exitStatus == 0,
                  let logContent = try? String(contentsOfFile: log.path),
                  !logContent.contains("error:") else {
                throw CompilerShellError.failed(command: "xcrun", information: result.stderr)
            }
            
            return ()
        }
    }
    
    private func target(platform: Platform) -> IO<CompilerShellError, String> {
        IO.invoke {
            let result = run("/usr/bin/xcode-select", args: ["-p"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.failed(command: "xcode-select", information: result.stderr)
            }
            
            let file = URL(fileURLWithPath: "\(result.stdout)/Platforms/\(platform.framework).platform/Developer/SDKs/\(platform.framework).sdk/SDKSettings.json")
            
            guard let content = try? String(contentsOf: file),
                  let rawBundleVersion = content.matches(pattern: "(?<=\"MinimalDisplayName\":\").*(?=\")").first,
                  let bundleVersion = rawBundleVersion.components(separatedBy: "\"").first,
                  let target = platform.target(bundleVersion: bundleVersion) else {
                    throw CompilerShellError.failed(command: "xcode-select", information: "can not extract CFBundleVersion from \(platform.framework)")
            }
            
            return target
        }
    }
}
