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
        .testTarget(name: "CoreTests", dependencies: ["Core"], path: "nef/Tests/CoreTests"),
        .target(name: "Core", dependencies: ["NefModels"], path: "nef/Core"),

        .target(name: "NefModels", path: "nef/Component/NefModels"),
        .target(name: "NefCarbon", dependencies: ["Core", "Common"], path: "nef/Component/NefCarbon"),
        .target(name: "nef", dependencies: ["NefCarbon", "NefModels"], path: "nef/Component/nef"),

        .target(name: "Common", path: "nef/UI/Common"),
        .target(name: "Markdown", dependencies: ["Core", "Common"], path: "nef/UI/Markdown"),
        .target(name: "Jekyll", dependencies: ["Core", "Common"], path: "nef/UI/Jekyll"),
        .target(name: "Carbon", dependencies: ["Core", "Common", "NefCarbon"], path: "nef/UI/Carbon"),
    ]
)
