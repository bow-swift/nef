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
    targets: [
        .target(name: "nef",
                path: "project",
                sources: ["nef",
                          "Core",
                          "Component/NefModels",
                          "Component/NefMarkdown",
                          "Component/NefJekyll",
                          "Component/NefCarbon"],
                publicHeadersPath: "Component/nef/Support Files"),


        .testTarget(name: "CoreTests", dependencies: ["nef"], path: "project/Tests/CoreTests"),
    ]
)
