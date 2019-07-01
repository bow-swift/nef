// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Markdown",
    products: [
        .library(name: "nef", targets: ["Nef"]),
    ],
    targets: [
        .target(name: "Markup", path: "lib/Markup"),
        .testTarget(name: "MarkupTests", path: "lib/MarkupTests"),
        .target(name: "Common", dependencies: [], path: "markdown/Common"),
        .target(name: "Markdown", dependencies: ["Markup", "Common"], path: "markdown/Markdown"),
        .target(name: "JekyllMarkdown", dependencies: ["Markup", "Common"], path: "markdown/JekyllMarkdown"),
        .target(name: "Carbon", dependencies: ["Markup", "Common"], path: "markdown/Carbon"),
        .target(name: "Nef", dependencies: ["Markdown", "JekyllMarkdown", "Carbon"], path: "markdown/Nef"),
    ]
)
