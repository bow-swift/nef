// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Markdown",
    products: [
        .executable(name: "nef-markdown-page", targets: ["Markdown"]),
        .executable(name: "nef-jekyll-page", targets: ["JekyllMarkdown"]),
        .executable(name: "nef-carbon-page", targets: ["Carbon"]),
    ],
    targets: [
        .target(name: "Markup", path: "lib/Markup"),
        .testTarget(name: "MarkupTests", path: "lib/MarkupTests"),
        .target(name: "Common", dependencies: [], path: "markdown/Common"),
        .target(name: "Markdown", dependencies: ["Markup", "Common"], path: "markdown/Markdown"),
        .target(name: "JekyllMarkdown", dependencies: ["Markup", "Common"], path: "markdown/JekyllMarkdown"),
        .target(name: "Carbon", dependencies: ["Markup", "Common"], path: "markdown/Carbon"),
    ]
)
