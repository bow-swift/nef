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
        
        .target(name: "NefCarbon", dependencies: ["Markup", "Common"], path: "markdown/NefCarbon"),
        .target(name: "Nef", dependencies: ["NefCarbon"], path: "markdown/Nef"),
        
        .target(name: "Markdown", dependencies: ["Markup", "Common"], path: "markdown/Markdown"),
        .target(name: "JekyllMarkdown", dependencies: ["Markup", "Common"], path: "markdown/JekyllMarkdown"),
        .target(name: "Carbon", dependencies: ["NefCarbon"], path: "markdown/Carbon"),
    ]
)
