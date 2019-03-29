import Foundation
import Markup

let scriptName = "nef-markdown-page"

func main() {
    guard let (from, to) = arguments() else { Console.help.show(); exit(-1) }
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


/// Console output
///
/// - error: show general error. The script fails.
/// - success: show general success. The script finishes successfully.
/// - help: show the help. How to use this script.
enum Console {
    case error
    case success
    case help

    func show() {
        switch self {
        case .error: printError()
        case .success: printSuccess()
        case .help: printHelp()
        }
    }

    private func printError() {
        print("error:\(scriptName) could not render the Markdown file ❌")
    }

    private func printSuccess() {
        print("RENDER SUCCEEDED")
    }

    private func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output markdown's file>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: is the path where render the markdown. ex. `/home`

             """)
    }
}


/// Get the parameters from the command line to configure the script.
///
/// In case the parameters are not correct or are incompleted it won't return anything.
///
/// - Returns: the parameters to configure the script: path to parser file and output path for render.
private func arguments() -> (from: String, to: String)? {
    var from: String?
    var to: String?

    func newCCharPtrFromStaticString(_ str: StaticString) -> UnsafePointer<CChar> {
        let rp = UnsafeRawPointer(str.utf8Start);
        let rplen = str.utf8CodeUnitCount;
        return rp.bindMemory(to: CChar.self, capacity: rplen);
    }

    enum OptLongCases: Int32 {
        case from = 0x68
        case to = 0x66
        case help
    }

    let longopts: [option] = [
        option(name: newCCharPtrFromStaticString("from"),      has_arg: required_argument, flag: nil, val: OptLongCases.from.rawValue),
        option(name: newCCharPtrFromStaticString("to"),        has_arg: required_argument, flag: nil, val: OptLongCases.to.rawValue),
        option(name: newCCharPtrFromStaticString("help"),      has_arg: no_argument,       flag: nil, val: OptLongCases.help.rawValue),
        option()
    ]

    while case let opt = getopt_long(CommandLine.argc, CommandLine.unsafeArgv, "fth:", longopts, nil), opt != -1 {
        switch (opt) {
        case OptLongCases.from.rawValue:
            from = "\(String(cString: optarg))/Contents.swift"
        case OptLongCases.to.rawValue:
            to = String(cString: optarg)

        default: // OptLongCases.help.rawValue
            return nil;
        }
    }

    if let from = from, let to = to {
        let filenameComponentes = from.components(separatedBy: "/")
        let filenameWithExtension = filenameComponentes[filenameComponentes.count-2]
        let filename = filenameWithExtension.components(separatedBy: ".").dropLast().joined(separator: ".")

        return (from, "\(to)/\(filename).md")
    } else {
        return nil
    }
}

// #: - MAIN <launcher>
main()
