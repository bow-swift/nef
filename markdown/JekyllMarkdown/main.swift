import Foundation
import Markup


func renderJekyll(from filePath: String, to outputPath: String, permalink: String) {
    let fileURL = URL(fileURLWithPath: filePath)
    let outputURL = URL(fileURLWithPath: outputPath)

    print("File: \(filePath)\nOutput: \(outputPath)")
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let rendered = JekyllGenerator(permalink: permalink).render(content: content),
          let _ = try? rendered.write(to: outputURL, atomically: true, encoding: .utf8) else { printError(); return }

    printSuccess()
}

// MARK: - Render information
private func printError() {
    print("ERROR")
}

private func printSuccess() {
    print("SUCCESS")
}

private func printHelp() {
    print("HELP")
}

// MARK: - Console
private func arguments() -> (from: String, to: String, permalink: String)? {
    guard CommandLine.arguments.count == 4 else { return nil }
    return (CommandLine.arguments[1], CommandLine.arguments[2], CommandLine.arguments[3])
}

// MARK: - MAIN
if let (from, to, permalink) = arguments() {
    renderJekyll(from: from, to: to, permalink: permalink)
} else {
    printHelp()
    exit(-1)
}

