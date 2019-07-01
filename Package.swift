// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Markdown",
    products: [
        .executable(name: "nef-markdown", targets: ["Markdown"]),
        .executable(name: "nef-jekyll", targets: ["JekyllMarkdown"]),
        .executable(name: "nef-carbon", targets: ["Carbon"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
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
