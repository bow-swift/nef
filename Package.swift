// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nef",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "nef",
                 targets: ["nef",
                           "NefCore",
                           "NefModels",
                           "NefMarkdown",
                           "NefJekyll",
                           "NefCarbon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bow-swift/bow", from: "0.6.0"),
    ],
    targets: [
        .target(name: "NefModels", path: "project/Component/NefModels", publicHeadersPath: "Support Files"),
        .target(name: "NefCore", dependencies: ["NefModels"], path: "project/Core", publicHeadersPath: "Support Files"),
        .target(name: "NefMarkdown", dependencies: ["NefCore"], path: "project/Component/NefMarkdown", publicHeadersPath: "Support Files"),
        .target(name: "NefJekyll", dependencies: ["NefCore"], path: "project/Component/NefJekyll", publicHeadersPath: "Support Files"),
        .target(name: "NefCarbon", dependencies: ["NefModels", "NefCore"], path: "project/Component/NefCarbon", publicHeadersPath: "Support Files"),
        
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
