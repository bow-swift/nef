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
        .package(url: "https://github.com/bow-swift/bow", from: "0.6.0"),
        .package(path: "project"),
    ],
    targets: [
        .target(name: "nef",
                dependencies: ["Bow", "BowEffects",
                               "NefCore",
                               "NefModels",
                               "NefMarkdown",
                               "NefJekyll",
                               "NefCarbon"],
                path: "project/Component/nef",
                publicHeadersPath: "Support Files"),
    ]
)
