// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "nef", targets: ["nef"]),
    ],
    targets: [
        .testTarget(name: "CoreTests", dependencies: ["Core"], path: "project/Tests/CoreTests"),
        .target(name: "Core", dependencies: ["NefModels"], path: "project/Core"),

        .target(name: "NefModels", path: "project/Component/NefModels"),
        .target(name: "NefCarbon", dependencies: ["Core"], path: "project/Component/NefCarbon"),
        .target(name: "NefJekyll", dependencies: ["Core"], path: "project/Component/NefJekyll"),
        .target(name: "NefMarkdown", dependencies: ["Core"], path: "project/Component/NefMarkdown"),
        .target(name: "nef", dependencies: ["NefMarkdown", "NefJekyll", "NefCarbon", "NefModels"], path: "project/Component/nef"),

        .target(name: "Common", path: "project/UI/Common"),
        .target(name: "Markdown", dependencies: ["Core", "Common", "NefMarkdown"], path: "project/UI/Markdown"),
        .target(name: "Jekyll", dependencies: ["Core", "Common", "NefJekyll"], path: "project/UI/Jekyll"),
        .target(name: "Carbon", dependencies: ["Core", "Common", "NefCarbon"], path: "project/UI/Carbon"),
    ]
)
