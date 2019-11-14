// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "NefModels", targets: ["NefModels"]),
        .library(name: "NefCore", targets: ["NefCore"]),
        .library(name: "NefMarkdown", targets: ["NefMarkdown"]),
        .library(name: "NefJekyll", targets: ["NefJekyll"]),
        .library(name: "NefCarbon", targets: ["NefCarbon"]),

        .executable(name: "nef-markdown-page", targets: ["MarkdownPage"]),
        .executable(name: "nef-jekyll-page", targets: ["JekyllPage"]),
        .executable(name: "nef-carbon-page", targets: ["CarbonPage"]),
    ],
    targets: [
        .target(name: "NefModels", path: "Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefModels", "NefCore"], path: "Component/NefCarbon", publicHeadersPath: "Support Files"),

        .target(name: "CLIKit", path: "UI/CLIKit", publicHeadersPath: "Support Files"),

        .target(name: "MarkdownPage", dependencies: ["CLIKit", "NefMarkdown"], path: "UI/MarkdownPage"),
        .target(name: "JekyllPage", dependencies: ["CLIKit", "NefJekyll"], path: "UI/JekyllPage"),
        .target(name: "CarbonPage", dependencies: ["CLIKit", "NefModels", "NefCore", "NefCarbon"], path: "UI/CarbonPage"),
    ]
)
