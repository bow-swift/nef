// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef", targets: ["nef"]),
    ],
    targets: [
        .testTarget(name: "CoreTests", dependencies: ["NefCore"], path: "project/Tests/CoreTests"),
        .target(name: "NefCommon", path: "project/Common", publicHeadersPath: "project/Common"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "project/Core", publicHeadersPath: "project/Core"),

        .target(name: "NefModels", path: "project/Component/NefModels"),
        .target(name: "NefCarbon", dependencies: ["NefCore"], path: "project/Component/NefCarbon", publicHeadersPath: "project/Component/NefCarbon"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "project/Component/NefJekyll", publicHeadersPath: "project/Component/NefJekyll"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "project/Component/NefMarkdown", publicHeadersPath: "project/Component/NefMarkdown"),
        .target(name: "nef", dependencies: ["NefMarkdown", "NefJekyll", "NefCarbon", "NefModels"], path: "project/Component/nef", publicHeadersPath: "project"),

        .target(name: "Markdown", dependencies: ["NefCore", "NefCommon", "NefMarkdown"], path: "project/UI/Markdown"),
        .target(name: "Jekyll", dependencies: ["NefCore", "NefCommon", "NefJekyll"], path: "project/UI/Jekyll"),
        .target(name: "Carbon", dependencies: ["NefCore", "NefCommon", "NefCarbon"], path: "project/UI/Carbon"),
    ]
)
