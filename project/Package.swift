// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "nefc",                targets: ["Compiler"]),
        .executable(name: "nef-markdown",        targets: ["Markdown"]),
        .executable(name: "nef-markdown-page",   targets: ["MarkdownPage"]),
        .executable(name: "nef-jekyll",          targets: ["Jekyll"]),
        .executable(name: "nef-jekyll-page",     targets: ["JekyllPage"]),
        .executable(name: "nef-carbon",          targets: ["Carbon"]),
        .executable(name: "nef-carbon-page",     targets: ["CarbonPage"]),
        .executable(name: "nef-playground-book", targets: ["PlaygroundBook"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", .branch("master")),
        .package(url: "https://github.com/bow-swift/Swiftline", .branch("master")),
    ],
    targets: [
        .target(name: "NefCommon", dependencies: ["Bow", "BowEffects", "BowOptics"], path: "Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefModels", dependencies: ["BowEffects"], path: "Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels", "NefCommon"], path: "Core", publicHeadersPath: "Support Files"),
        .target(name: "NefRender", dependencies: ["NefCore"], path: "Component/NefRender", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefRender"], path: "Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefRender"], path: "Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefRender"], path: "Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefCompiler", dependencies: ["NefRender"], path: "Component/NefCompiler", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["NefModels", "NefCommon"], path: "Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),

        .testTarget(name: "CoreTests", dependencies: ["NefCore"], path: "Tests/CoreTests"),

        .target(name: "nef", dependencies: ["Swiftline",
                                            "NefCore",
                                            "NefCommon",
                                            "NefCompiler",
                                            "NefMarkdown",
                                            "NefJekyll",
                                            "NefCarbon",
                                            "NefSwiftPlayground"], path: "Component/nef", publicHeadersPath: "Support Files"),
        .target(name: "CLIKit", dependencies: ["nef"], path: "UI/CLIKit", publicHeadersPath: "Support Files"),

        .target(name: "Compiler",       dependencies: ["CLIKit", "nef"], path: "UI/Compiler"),
        .target(name: "Markdown",       dependencies: ["CLIKit", "nef"], path: "UI/Markdown"),
        .target(name: "MarkdownPage",   dependencies: ["CLIKit", "nef"], path: "UI/MarkdownPage"),
        .target(name: "Jekyll",         dependencies: ["CLIKit", "nef"], path: "UI/Jekyll"),
        .target(name: "JekyllPage",     dependencies: ["CLIKit", "nef"], path: "UI/JekyllPage"),
        .target(name: "Carbon",         dependencies: ["CLIKit", "nef"], path: "UI/Carbon"),
        .target(name: "CarbonPage",     dependencies: ["CLIKit", "nef"], path: "UI/CarbonPage"),
        .target(name: "PlaygroundBook", dependencies: ["CLIKit", "nef"], path: "UI/PlaygroundBook"),
    ]
)
