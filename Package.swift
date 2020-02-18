// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef", targets: ["nef", "NefModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", .branch("master")),
        .package(url: "https://github.com/bow-swift/Swiftline", .exact("0.5.4")),
    ],
    targets: [
        .target(name: "NefModels", dependencies: ["BowEffects"], path: "project/Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCommon", dependencies: ["Bow", "BowEffects", "BowOptics", "NefModels"], path: "project/Component/NefCommon", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefCommon"], path: "project/Core", publicHeadersPath: "Support Files"),
        .target(name: "NefRender", dependencies: ["NefCore"], path: "project/Component/NefRender", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefRender"], path: "project/Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefRender"], path: "project/Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefRender"], path: "project/Component/NefCarbon", publicHeadersPath: "Support Files"),
        .target(name: "NefCompiler", dependencies: ["NefRender"], path: "project/Component/NefCompiler", publicHeadersPath: "Support Files"),
        .target(name: "NefPlayground", dependencies: ["NefCommon"], path: "project/Component/NefPlayground", publicHeadersPath: "Support Files"),
        .target(name: "NefSwiftPlayground", dependencies: ["NefCommon"], path: "project/Component/NefSwiftPlayground", publicHeadersPath: "Support Files"),

        .target(name: "nef",
                dependencies: ["Swiftline",
                               "NefCore",
                               "NefCompiler",
                               "NefMarkdown",
                               "NefJekyll",
                               "NefCarbon",
                               "NefPlayground",
                               "NefSwiftPlayground"],
                path: "project/Component/nef",
                publicHeadersPath: "Support Files"),
    ]
)
