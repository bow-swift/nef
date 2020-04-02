// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "nef",                 targets: ["NefMenu"]),
        .executable(name: "nefc",                targets: ["Compiler"]),
        .executable(name: "nef-clean",           targets: ["Clean"]),
        .executable(name: "nef-markdown",        targets: ["Markdown"]),
        .executable(name: "nef-markdown-page",   targets: ["MarkdownPage"]),
        .executable(name: "nef-jekyll",          targets: ["Jekyll"]),
        .executable(name: "nef-jekyll-page",     targets: ["JekyllPage"]),
        .executable(name: "nef-carbon",          targets: ["Carbon"]),
        .executable(name: "nef-carbon-page",     targets: ["CarbonPage"]),
        .executable(name: "nef-playground",      targets: ["Playground"]),
        .executable(name: "nef-playground-book", targets: ["PlaygroundBook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", .branch("master")),
        .package(url: "https://github.com/bow-swift/Swiftline", .exact("0.5.4")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(name: "NefModels", dependencies: ["Bow", "BowEffects", "BowOptics"], path: "Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCommon", dependencies: ["NefModels"], path: "Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefCommon"], path: "Core", publicHeadersPath: "Support Files"),
        .target(name: "NefRender", dependencies: ["NefCore"], path: "Component/NefRender", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefRender"], path: "Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefRender"], path: "Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefRender"], path: "Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefCompiler", dependencies: ["NefRender"], path: "Component/NefCompiler", publicHeadersPath: "Support Files"),
        .target(name: "NefClean", dependencies: ["NefCommon"], path: "Component/NefClean", publicHeadersPath: "Support Files"),
        .target(name: "NefPlayground", dependencies: ["NefCommon"], path: "Component/NefPlayground", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["NefCommon"], path: "Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),

        .testTarget(name: "CoreTests", dependencies: ["NefCore"], path: "Tests/CoreTests"),

        .target(name: "nef",
                dependencies: ["Swiftline",
                               "NefCore",
                               "NefCompiler",
                               "NefClean",
                               "NefMarkdown",
                               "NefJekyll",
                               "NefCarbon",
                               "NefPlayground",
                               "NefSwiftPlayground"],
                path: "Component/nef",
                publicHeadersPath: "Support Files"),

        .target(name: "CLIKit",
                dependencies: ["nef", "ArgumentParser"],
                path: "UI",
                exclude: ["Nef/main.swift",
                          "Compiler/main.swift",
                          "Clean/main.swift",
                          "Markdown/main.swift",
                          "MarkdownPage/main.swift",
                          "Jekyll/main.swift",
                          "JekyllPage/main.swift",
                          "Carbon/main.swift",
                          "CarbonPage/main.swift",
                          "Playground/main.swift",
                          "PlaygroundBook/main.swift"],
                publicHeadersPath: "CLIKit/Support Files"),

        .target(name: "NefMenu",        dependencies: ["CLIKit", "nef"], path: "UI/Nef",            sources: ["main.swift"]),
        .target(name: "Compiler",       dependencies: ["CLIKit", "nef"], path: "UI/Compiler",       sources: ["main.swift"]),
        .target(name: "Clean",          dependencies: ["CLIKit", "nef"], path: "UI/Clean",          sources: ["main.swift"]),
        .target(name: "Markdown",       dependencies: ["CLIKit", "nef"], path: "UI/Markdown",       sources: ["main.swift"]),
        .target(name: "MarkdownPage",   dependencies: ["CLIKit", "nef"], path: "UI/MarkdownPage",   sources: ["main.swift"]),
        .target(name: "Jekyll",         dependencies: ["CLIKit", "nef"], path: "UI/Jekyll",         sources: ["main.swift"]),
        .target(name: "JekyllPage",     dependencies: ["CLIKit", "nef"], path: "UI/JekyllPage",     sources: ["main.swift"]),
        .target(name: "Carbon",         dependencies: ["CLIKit", "nef"], path: "UI/Carbon",         sources: ["main.swift"]),
        .target(name: "CarbonPage",     dependencies: ["CLIKit", "nef"], path: "UI/CarbonPage",     sources: ["main.swift"]),
        .target(name: "Playground",     dependencies: ["CLIKit", "nef"], path: "UI/Playground",     sources: ["main.swift"]),
        .target(name: "PlaygroundBook", dependencies: ["CLIKit", "nef"], path: "UI/PlaygroundBook", sources: ["main.swift"]),
    ]
)
