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
        .package(url: "https://github.com/bow-swift/bow", .branch("master")),
        .package(url: "https://github.com/bow-swift/Swiftline", from: "0.5.3"),
    ],
    targets: [
        .target(name: "NefCommon", path: "project/Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefModels", dependencies: ["BowEffects"], path: "project/Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "project/Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "project/Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "project/Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefModels", "NefCore"], path: "project/Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["Bow", "BowEffects", "BowOptics", "NefModels", "NefCommon"], path: "project/Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),

        .target(name: "nef",
                dependencies: ["Bow", "BowEffects", "Swiftline",
                               "NefCore",
                               "NefCommon",
                               "NefModels",
                               "NefMarkdown",
                               "NefJekyll",
                               "NefCarbon",
                               "NefSwiftPlayground"],
                path: "project/Component/nef",
                publicHeadersPath: "Support Files"),
    ]
)
