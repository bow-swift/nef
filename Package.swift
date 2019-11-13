// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef", targets: ["nef"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", from: "0.6.0")
    ],
    targets: [
        .target(name: "nef",
                dependencies: ["Bow", "BowEffects"],
                path: "project",
                sources: ["Core",
                          "Component/nef",
                          "Component/NefModels",
                          "Component/NefMarkdown",
                          "Component/NefJekyll",
                          "Component/NefCarbon"],
                publicHeadersPath: "Component/nef/Support Files"),
    ]
)
