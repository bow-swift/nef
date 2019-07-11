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
        .target(name: "nef", dependencies: ["NefCarbon", "NefModels"], path: "project/Component/nef"),

        .target(name: "Common", path: "project/UI/Common"),
        .target(name: "Markdown", dependencies: ["Core", "Common"], path: "project/UI/Markdown"),
        .target(name: "Jekyll", dependencies: ["Core", "Common"], path: "project/UI/Jekyll"),
        .target(name: "Carbon", dependencies: ["Core", "Common", "NefCarbon"], path: "project/UI/Carbon"),
    ]
)
