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
    
    func compile(file: URL, sources: [URL], platform: Platform, frameworks: [URL], linkers: [URL]) -> IO<CompilerShellError, Void> {
        fatalError("TODOOO")
        
        
        
        //        # A. macOS paltform
        //        if [ "$platformIOS" -eq "0" ]; then
        //            if [ "${#hasSourceFolderFiles}" -gt 0 ]; then
        //              xcrun -k swiftc -D NOT_IN_PLAYGROUND -F "nef/build/fw" -F "$macOSFwPath" -Xlinker -rpath -Xlinker "$macOSFwPath" -lswiftCore "$file" "$sources"/* -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            else
        //              xcrun -k swiftc -D NOT_IN_PLAYGROUND -F "nef/build/fw" -F "$macOSFwPath" -Xlinker -rpath -Xlinker "$macOSFwPath" -lswiftCore "$file" -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            fi
        //
        //        # B. iOS platform
        //        else
        //            if [ "${#hasSourceFolderFiles}" -gt 0 ]; then
        //              xcrun -k -sdk "iphoneos" swiftc -D NOT_IN_PLAYGROUND -target "arm64-apple-ios13.0" -F "nef/build/fw" -F "$iOSFwPath" -Xlinker -rpath -Xlinker "$iOSFwPath" -lswiftXCTest "$file" "$sources"/* -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            else
        //              xcrun -k -sdk "iphoneos" swiftc -D NOT_IN_PLAYGROUND -target "arm64-apple-ios13.0" -F "nef/build/fw" -F "$iOSFwPath" -Xlinker -rpath -Xlinker "$iOSFwPath" -lswiftXCTest "$file" -o "nef/build/output/$playgroundName" 1> "$log" 2>&1
        //            fi
        //        fi
    }
}
