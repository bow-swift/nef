// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "nef-markdown-page", targets: ["MarkdownPage"]),
        .executable(name: "nef-jekyll-page", targets: ["JekyllPage"]),
        .executable(name: "nef-carbon-page", targets: ["CarbonPage"]),
    ],
    targets: [
        .target(name: "CLIKit", path: ".", sources: ["Component/NefMarkdown",
                                                     "Component/NefJekyll",
                                                     "Component/NefCarbon",
                                                     "Component/NefModels",
                                                     "UI/CLIKit",
                                                     "Core"], publicHeadersPath: "UI/CLIKit/Support Files"),
        
        .target(name: "MarkdownPage", dependencies: ["CLIKit"], path: ".", sources: ["UI/MarkdownPage"]),
        .target(name: "JekyllPage", dependencies: ["CLIKit"], path: ".", sources: ["UI/JekyllPage"]),
        .target(name: "CarbonPage", dependencies: ["CLIKit"], path: ".", sources: ["UI/CarbonPage"]),
    ]
)
