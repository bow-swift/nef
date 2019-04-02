import Foundation
import Markup

let scriptName = "nef-markdown-page"

func main() {
    let result = arguments(keys: "from", "to")
    guard let from = result["from"], let to = result["to"] else { Console.help.show(); exit(-1) }
    renderMarkdown(from: from, to: to)
}


/// Method to render a page into Markdown format.
///
/// - Parameters:
///   - filePath: input page in Apple's playground format.
///   - outputPath: output where to write the Markdown render.
func renderMarkdown(from filePath: String, to outputPath: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
        let rendered = MarkdownGenerator().render(content: content),
        let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { Console.error.show(); return }

    Console.success.show()
}




// #: - MAIN <launcher>
main()
