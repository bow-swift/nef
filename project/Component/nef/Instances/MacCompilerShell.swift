//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCompiler
import Swiftline
import Bow
import BowEffects

final class MacCompilerShell: CompilerShell {
    
    func podinstall(project: URL, platform: Platform, cached: Bool) -> IO<CompilerShellError, Void> {
        IO.invoke {
            let result = run("pod", args: cached ? ["install", "--project-directory=\(project.path)"]
                                                 : ["install", "--repo-update", "--project-directory=\(project.path)"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.failed(command: "pod", info: "error: \(result.stderr) - output:\(result.stdout) install cocoapods using `gem install cocoapods`")
            }
            
            return ()
        }
    }
    
    func carthage(project: URL, platform: Platform, cached: Bool) -> EnvIO<FileSystem, CompilerShellError, Void> {
        func resolve(carthage: URL, project: URL, platform: Platform, cached: Bool) -> EnvIO<FileSystem, CompilerShellError, Void> {
            EnvIO.invoke { _ in
                _ = run("chmod", args: "+x", carthage.path)
                let result = run(carthage.path, args: cached ? ["bootstrap", "--cache-builds", "--platform", platform == .ios ? "ios" : "osx", "--project-directory", project.path]
                                                             : ["update", "--platform", platform == .ios ? "ios" : "osx", "--project-directory", project.path])
                guard result.exitStatus == 0 else {
                    throw CompilerShellError.failed(command: "carthage", info: "error: \(result.stderr) - output: \(result.stdout) install carthage using `brew install carthage`")
                }
                
                return ()
            }
        }
        
        func fixCarthageLipo(project: URL) -> EnvIO<FileSystem, CompilerShellError, URL> {
            EnvIO { fileSystem in
                let xcconfigFile = project.appendingPathComponent("carthage.sh")
                let xcconfigContent =  """
                                       #!/usr/bin/env bash
                                       set -euo pipefail
                                       xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
                                       trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

                                       echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
                                       echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

                                       export XCODE_XCCONFIG_FILE="$xcconfig"
                                       carthage "$@"
                                       """
                
                let removeIO = fileSystem.remove(itemPath: xcconfigFile.path).handleError { _ in }
                let xcconfigIO = fileSystem.write(content: xcconfigContent, toFile: xcconfigFile.path)
                
                return removeIO.followedBy(xcconfigIO).as(xcconfigFile)^
                    .mapError { e in
                        .failed(command: "carthage",
                                info: "\(e). Remove 'arm64' architecture from iphone-simulator.")
                    }^
            }
        }
        
        let carthage = EnvIO<FileSystem, CompilerShellError, URL>.var()
        
        return binding(
            carthage <- fixCarthageLipo(project: project),
                     |<-resolve(carthage: carthage.get, project: project, platform: platform, cached: cached),
        yield: ())^
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
                throw CompilerShellError.failed(command: "xcodebuild", info: result.stderr)
            }
            
            return ()
        }
    }
    
    func dependencies(platform: Platform) -> IO<CompilerShellError, URL> {
        activeDeveloperDirectory(platform: platform).map { url in
            url.appendingPathComponent("Library/Frameworks")
        }^
    }
    
    func libraries(platform: Platform) -> IO<CompilerShellError, URL> {
        activeDeveloperDirectory(platform: platform).map { url in
            url.appendingPathComponent("/usr/lib")
        }^
    }
    
    func compile(file: URL, options: CompilerOptions, output: URL, log: URL) -> IO<CompilerShellError, Void> {
        let target = IO<CompilerShellError, String>.var()
        let isM1 = IO<CompilerShellError, Bool>.var()
        
        return binding(
              isM1 <- self.isUsingM1(),
            target <- self.target(platform: options.workspace.platform, isM1: isM1.get),
                   |<-self.compile(file: file, target: target.get, options: options, output: output, log: log),
        yield: ())^
    }
    
    // MARK: private methods
    private func isUsingM1() -> IO<CompilerShellError, Bool> {
        IO.invoke {
            let result = run("uname", args: ["-m"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.failed(command: "check M1 processor", info: result.stderr)
            }
            return result.stdout == "arm64"
        }
    }

    private func compile(file: URL, target: String, options: CompilerOptions, output: URL, log: URL) -> IO<CompilerShellError, Void> {
        IO.invoke {
            let sdk = options.workspace.platform.sdk
            let linkFrameworks = (options.workspace.frameworks + options.workspace.linkers).flatMap { fw in ["-F", fw.path] }
            let linkModules = options.workspace.modules.flatMap { module in ["-I", module.path] }
            let linkBinaries = options.workspace.binaries.map(\.path)
            let xlinkers = options.workspace.linkers.flatMap { linker in ["-Xlinker", linker.path] }
            let linkLibs = options.workspace.libs.flatMap { lib in ["-L", lib.path] }
            let sourcesPaths = options.sources.map { (source: URL) in source.path }
            let linkSwiftCore = options.workspace.platform == .ios ? ["-lXCTestSwiftSupport"]
                                                                   : ["-lswiftCore", "-lXCTestSwiftSupport"]

            let args = ["-k"]                                     // invalidate all existing cache entries
                        .append("-sdk").append(sdk)               // find the tool for the given SDK name
                        .append("swiftc")                         // swift compiler
                        .append("-D").append("NOT_IN_PLAYGROUND") // allow use `import PlaygroundSupport` and utils outside Xcode Playgrounds
                        .append("-target").append(target)         // generate code for the given target
                        .appending(contentsOf: linkFrameworks)    // add directories to frameworks search path
                        .appending(contentsOf: linkModules)       // add swift-modules directories to the import search path
                        .appending(contentsOf: linkLibs)          // add directories to libraries search path
                        .append("-Xlinker").append("-rpath")      // -Xlinker, specifies an option which should be passed to the linker
                        .appending(contentsOf: xlinkers)
                        .appending(contentsOf: linkSwiftCore)     // -l, specifies a library which should be linked against
                        .appending(contentsOf: sourcesPaths)      // sources to link against main.swift
                        .appending(contentsOf: linkBinaries)      // link .swiftmodules binaries
                        .append(file.path)                        // main.swift - allow top level function (playground)
                        .append("-o").append(output.path.removeExtension)
            
            let result = run("/usr/bin/xcrun", args: args) { settings in settings.execution = .log(file: log.path) }
            
            guard result.exitStatus == 0,
                  let logContent = try? String(contentsOfFile: log.path),
                  !logContent.contains("error:") else {
                throw CompilerShellError.failed(command: "xcrun", info: result.stderr)
            }
            
            return ()
        }
    }
    
    private func target(platform: Platform, isM1: Bool) -> IO<CompilerShellError, String> {
        activeDeveloperDirectory(platform: platform).flatMap { url in
            IO.invoke {
                let settings = url.appendingPathComponent("SDKs/\(platform.framework).sdk/SDKSettings.json")
                guard let content = try? String(contentsOf: settings),
                      let rawBundleVersion = content.matches(pattern: "(?<=\"MinimalDisplayName\":\").*(?=\")").first,
                      let bundleVersion = rawBundleVersion.components(separatedBy: "\"").first,
                      let target = platform.target(bundleVersion: bundleVersion, isM1: isM1) else {
                        throw CompilerShellError.failed(command: "target(platform:)", info: "can not extract CFBundleVersion from \(platform.framework)")
                }
                
                return target
            }^
        }^
    }
    
    private func activeDeveloperDirectory(platform: Platform) -> IO<CompilerShellError, URL> {
        IO.invoke {
            let result = run("/usr/bin/xcode-select", args: ["-p"])
            guard result.exitStatus == 0 else {
                throw CompilerShellError.failed(command: "xcode-select", info: result.stderr)
            }
            
            return URL(fileURLWithPath: "\(result.stdout)/Platforms/\(platform.framework).platform/Developer")
        }
    }
}
