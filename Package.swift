// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef", targets: ["NefModels", "nef"]),
        .executable(name: "nef-markdown-page", targets: ["Markdown"]),
        .executable(name: "nef-jekyll-page", targets: ["Jekyll"]),
        .executable(name: "nef-carbon-page", targets: ["Carbon"]),
    ],
    targets: [
        .target(name: "NefCommon", path: "project/Common", publicHeadersPath: "Support Files"),
        .target(name: "NefModels", path: "project/Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "project/Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "project/Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "project/Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefCore"], path: "project/Component/NefCarbon", publicHeadersPath: "Support Files"),

        .target(name: "nef", dependencies: ["NefModels", "NefMarkdown", "NefJekyll", "NefCarbon"], path: "project/Component/nef", publicHeadersPath: "Support Files/Public", cSettings: [.headerSearchPath("Support Files/Private")]),
        .target(name: "Markdown", dependencies: ["NefCommon", "NefMarkdown"], path: "project/UI/Markdown"),
        .target(name: "Jekyll", dependencies: ["NefCommon", "NefJekyll"], path: "project/UI/Jekyll"),
        .target(name: "Carbon", dependencies: ["NefCommon", "NefModels", "NefCore", "NefCarbon"], path: "project/UI/Carbon"),
            
        .testTarget(name: "CoreTests", dependencies: ["nef"], path: "project/Tests/CoreTests"),
    ]
)
