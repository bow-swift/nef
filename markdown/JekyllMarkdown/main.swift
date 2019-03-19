import Foundation
import Markup

let scriptName = "nef-jekyll-page"

func main() {
    guard let (from, to, permalink) = arguments() else { Console.help.show(); exit(-1) }
    renderJekyll(from: from, to: to, permalink: permalink)
}


/// Method to render a page into Jekyll format.
///
/// - Parameters:
///   - filePath: input page in Apple's playgorund format.
///   - outputPath: output where to write the Jekyll render.
///   - permalink: website's relative url where locate the page.
func renderJekyll(from filePath: String, to outputPath: String, permalink: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let rendered = JekyllGenerator(permalink: permalink).render(content: content),
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
        print("error:\(scriptName) could not render the Jekyll's file ❌")
    }

    private func printSuccess() {
        print("RENDER SUCCEEDED")
    }

    private func printHelp() {
        print("\(scriptName) --from <playground's page> --to <output Jekyll's markdown> --permalink <relative URL>")
        print("""

                    from: is the path to playground page. ex. `/home/nef.playground/Pages/Intro.xcplaygroundpage`
                    to: is the path where render the Jekyll markdown. ex. `/home`
                    permalink: is the relative path where Jekyll will render the documentation. ex. `/about/`

             """)
    }
}


/// Get the parameters from the command line to configure the script.
///
/// In case the parameters are not correct or are incompleted it won't return anything.
///
/// - Returns: the parameters to configure the script: path to parser file, output path
/// for render and the permalink.
private func arguments() -> (from: String, to: String, permalink: String)? {
    var from: String?
    var to: String?
    var permalink: String?

    func newCCharPtrFromStaticString(_ str: StaticString) -> UnsafePointer<CChar> {
        let rp = UnsafeRawPointer(str.utf8Start);
        let rplen = str.utf8CodeUnitCount;
        return rp.bindMemory(to: CChar.self, capacity: rplen);
    }

    enum OptLongCases: Int32 {
        case from = 0x68
        case to = 0x66
        case permalink = 0x64
        case help
    }

    let longopts: [option] = [
        option(name: newCCharPtrFromStaticString("from"),      has_arg: required_argument, flag: nil, val: OptLongCases.from.rawValue),
        option(name: newCCharPtrFromStaticString("to"),        has_arg: required_argument, flag: nil, val: OptLongCases.to.rawValue),
        option(name: newCCharPtrFromStaticString("permalink"), has_arg: required_argument, flag: nil, val: OptLongCases.permalink.rawValue),
        option(name: newCCharPtrFromStaticString("help"),      has_arg: no_argument,       flag: nil, val: OptLongCases.help.rawValue),
        option()
    ]

    while case let opt = getopt_long(CommandLine.argc, CommandLine.unsafeArgv, "ftph:", longopts, nil), opt != -1 {
        switch (opt) {
        case OptLongCases.from.rawValue:
            from = "\(String(cString: optarg))/Contents.swift"
        case OptLongCases.to.rawValue:
            to = "\(String(cString: optarg))/README.md"
        case OptLongCases.permalink.rawValue:
            permalink = String(cString: optarg);

        default: // OptLongCases.help.rawValue
            return nil;
        }
    }

    if let from = from, let to = to, let permalink = permalink {
        return (from, to, permalink)
    } else {
        return nil
    }
}

// #: - MAIN <launcher>
main()
