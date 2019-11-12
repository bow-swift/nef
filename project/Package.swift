// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef-bin",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "nef-markdown-page", targets: ["Markdown"]),
        .executable(name: "nef-jekyll-page", targets: ["Jekyll"]),
        .executable(name: "nef-carbon-page", targets: ["Carbon"]),
    ],
    targets: [
        .target(name: "Common", path: ".", sources: ["Component/NefMarkdown",
                                                     "Component/NefJekyll",
                                                     "Component/NefCarbon",
                                                     "UI/Common",
                                                     "Component/NefModels",
                                                     "Core"], publicHeadersPath: "UI/Common/Support Files"),
        
        .target(name: "Markdown", dependencies: ["Common"], path: ".", sources: ["UI/Markdown"]),
        .target(name: "Jekyll", dependencies: ["Common"], path: ".", sources: ["UI/Jekyll"]),
        .target(name: "Carbon", dependencies: ["Common"], path: ".", sources: ["UI/Carbon"]),
    ]
)
