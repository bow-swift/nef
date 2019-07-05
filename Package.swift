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
        .target(name: "Common", path: "core/ui/Common"),
        .target(name: "NefModels", path: "core/ui/NefModels"),
        .target(name: "Markup", dependencies: ["NefModels"], path: "core/lib/Markup"),
        .testTarget(name: "MarkupTests", dependencies: ["Markup"], path: "core/lib/MarkupTests"),

        .target(name: "NefCarbon", dependencies: ["Markup", "Common"], path: "core/ui/NefCarbon"),
        .target(name: "nef", dependencies: ["NefCarbon", "NefModels"], path: "core/ui/nef"),

        .target(name: "Markdown", dependencies: ["Markup", "Common"], path: "core/ui/Markdown"),
        .target(name: "Jekyll", dependencies: ["Markup", "Common"], path: "core/ui/Jekyll"),
        .target(name: "Carbon", dependencies: ["Markup", "Common", "NefCarbon"], path: "core/ui/Carbon"),
    ]
)
