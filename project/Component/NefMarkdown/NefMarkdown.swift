//  Copyright © 2019 The nef Authors.

import NefCommon
import NefModels
import NefCore

import Bow
import BowEffects

public struct Markdown {
    private let output: URL
    private let generator = MarkdownGenerator()
    
    public init(output: URL) {
        self.output = output
    }
    
    public func buildPage(content: String, filename: String) -> EnvIO<MarkdownSystem, MarkdownError, RendererOutput> {
        func renderPage(generator: MarkdownGenerator, content: String) -> IO<MarkdownError, RendererOutput> {
            IO.async { callback in
                if let rendered = self.generator.render(content: content) {
                    callback(.right(rendered))
                } else {
                    callback(.left(.renderPage))
                }
            }^
        }
        
        return EnvIO { fileSystem in
            let renderer = IOPartial<MarkdownError>.var(RendererOutput.self)
            let file = self.output.appendingPathComponent(filename)
            
            return binding(
              renderer <- renderPage(generator: self.generator, content: content),
                       |<-fileSystem.write(content: renderer.get.output, toFile: file)
                                    .mapLeft { _ in MarkdownError.create(file: file) },
            yield: renderer.get)
        }^
    }
    
    public func build(playground: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        fatalError()
    }
    
    public func buildPlaygrounds(at folder: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, [URL]> {
        fatalError()
    }
    
    // MARK: steps
    private func step(_ number: UInt, duration: DispatchTimeInterval = .seconds(3)) -> Step { Step(total: 5, partial: number, duration: duration) }
    
    private func structure(step: Step, output: URL) -> EnvIO<MarkdownEnvironment, MarkdownError, Void> {
        EnvIO { env in
            binding(
                |<-env.shell.out.printStep(step: step, information: "Creating folder structure (\(output.path))"),
                |<-env.system.createDirectory(at: output).mapLeft { _ in .structure },
            yield: ())^.reportStatus(step: step, in: env.shell.out, verbose: false)
        }
    }
    
    // MARK: steps <helpers>
}


//buildMarkdown() {
//    local projectPath="$1" # parameter 'projectPath'
//    local outputPath="$2"  # parameter 'outputPath'
//
//    playgrounds "$projectPath"
//
//    for playgroundPath in "${playgroundsPaths[@]}"; do
//        playgroundName=`echo "$playgroundPath" | rev | cut -d'/' -f -1 | cut -d'.' -f 2- | rev`
//        output="$outputPath/$playgroundName"
//
//        echo -ne "${normal}Rendering Markdown files for ${green}$playgroundName${reset}..."
//
//        checkOutputNotSameInput "$output" "$projectPath"
//        resetStructure "$output"
//        mkdir -p "$output"
//        pagesInPlayground "$playgroundPath"
//
//        for pagePath in "${pagesInPlayground[@]}"; do
//            pageName=`echo "$pagePath" | rev | cut -d'/' -f -1 | cut -d'.' -f 2- | rev`
//            log="$1/$LOG_PATH/$playgroundName-$pageName.log"
//
//            nef-markdown-page --from "$pagePath" --to "$output" --filename "$pageName" 1> "$log" 2>&1
//
//            installed=`grep "RENDER SUCCEEDED" "$log"`
//            if [ "${#installed}" -lt 7 ]; then
//              echo " ❌"
//              echo "${bold}${red}error: ${reset}render page ${bold}$pageName${normal} in playground ${bold}$playgroundName${normal}, review '$log' for more information."
//              exit 1
//
//            fi
//        done
//
//        echo " ✅"
//    done
//}
//
