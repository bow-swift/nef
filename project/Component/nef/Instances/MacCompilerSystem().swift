//  Copyright © 2020 The nef Authors.

import Foundation
import NefCommon
import NefCompiler
import Bow
import BowEffects


class MacCompilerSystem: CompilerSystem {
    func compile(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        binding(
            |<-self.buildPods(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildCarthage(xcworkspace: xcworkspace, platform: platform, cached: cached),
            |<-self.buildProject(xcworkspace: xcworkspace, platform: platform, cached: cached),
        yield: ())^
    }
    
    func compile(page: RenderingOutput<String>) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        fatalError()
//        let content = page.output.all().combineAll()
//        return reorganizeHeaders(page: content).map { _ in }^
    }
    
    // MARK: helpers
    private func reorganizeHeaders(page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
        func getImports(page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]> {
            EnvIO.pure(Array(Set(
                page.matches(pattern: "(?<=import).*(?=\n)"))).map { fw in
                    fw.trimmingCharacters(in: .whitespaces)
                }
            )^
        }
        
        func removeImports(_ imports: [String], inPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.reduce(page) { (acc, fw) in
                    acc.replacingOccurrences(of: "import \(fw)", with: "")
                }
            )^
        }
        
        func insertHeaders(_ imports: [String], toPage page: String) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, String> {
            EnvIO.pure(
                imports.sorted(by: >).reduce(page) { (acc, fw) in
                    "import \(fw)\n\(acc)"
                }
            )^
        }
        
        let imports = EnvIO<CompilerSystemEnvironment, CompilerSystemError, [String]>.var()
        let cleaned = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        let output  = EnvIO<CompilerSystemEnvironment, CompilerSystemError, String>.var()
        
        return binding(
            imports <- getImports(page: page),
            cleaned <- removeImports(imports.get, inPage: page),
             output <- insertHeaders(imports.get, toPage: cleaned.get),
        yield: output.get)^
    }
    
    // MARK: operations <shell>
    private func buildPods(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        func checkPodfile(atFolder folder: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
            EnvIO { env in
                env.fileSystem.exist(itemPath: folder.appendingPathComponent("Podfile").path)
                    ? IO.pure(())^
                    : IO.raiseError(.dependencies(folder))
            }
        }
        
        func resolve(project: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerShell, CompilerSystemError, Void> {
            EnvIO { shell in
                shell.podinstall(project: project, platform: platform, cached: cached)
            }.mapError { e in .dependencies(project, information: "\(e)") }^
        }
        
        let project = xcworkspace.deletingLastPathComponent()
        return binding(
                |<-checkPodfile(atFolder: project),
                |<-resolve(project: project, platform: platform, cached: cached).contramap(\CompilerSystemEnvironment.shell),
        yield: ())^
    }
    
    private func buildCarthage(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        let folder = xcworkspace.deletingLastPathComponent()
        fatalError()
    }
    
    private func buildProject(xcworkspace: URL, platform: Platform, cached: Bool) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
        fatalError()
    }
    
    // MARK: operations <filesystem>
//    func createEmptyWorkspace(at folder: URL) -> EnvIO<CompilerSystemEnvironment, CompilerSystemError, Void> {
//        fatalError()
//    }
}
