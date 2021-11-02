// swift-tools-version:5.2
import PackageDescription

// MARK: - Target.Dependencies
extension Target.Dependency {
    static var bow: Target.Dependency {
        .product(name: "Bow", package: "Bow")
    }
    
    static var bowEffects: Target.Dependency {
        .product(name: "BowEffects", package: "Bow")
    }
    
    static var bowOptics: Target.Dependency {
        .product(name: "BowOptics", package: "Bow")
    }
    
    static var swiftLine: Target.Dependency {
        .product(name: "Swiftline", package: "Swiftline")
    }
}

extension Target {
    var asDependency: Target.Dependency {
        .target(name: name)
    }
}

// MARK: - Libraries
extension Target {
    static var modules: [Target] {
        #if os(Linux)
        return [
            .nefModels,
            .nefCommon,
            .nefCore,
            .nefRender,
            .nefMarkdown,
            .nefJekyll,
            .nefPlaygroundBook,
        ]
        #else
        return [
            .nefModels,
            .nefCommon,
            .nefCore,
            .nefRender,
            .nefMarkdown,
            .nefJekyll,
            .nefCarbon,
            .nefCompiler,
            .nefClean,
            .nefPlayground,
            .nefPlaygroundBook,
        ]
        #endif
    }

    static var nefModels: Target {
        #if os(Linux)
        return .target(name: "NefModels",
                       dependencies: [.bow,
                                      .bowEffects,
                                      .bowOptics],
                       path: "project/Component/NefModels",
                       exclude: ["CarbonView.swift"])
        #else
        return .target(name: "NefModels",
                       dependencies: [.bow,
                                      .bowEffects,
                                      .bowOptics],
                       path: "project/Component/NefModels")
        #endif
    }
    
    static var nefCommon: Target {
        .target(name: "NefCommon",
                dependencies: [nefModels.asDependency],
                path: "project/Component/NefCommon")
    }
    
    static var nefCore: Target {
        .target(name: "NefCore",
                dependencies: [nefCommon.asDependency],
                path: "project/Core")
    }
    
    static var nefRender: Target {
        .target(name: "NefRender",
                dependencies: [nefCore.asDependency],
                path: "project/Component/NefRender")
    }
    
    static var nefMarkdown: Target {
        .target(name: "NefMarkdown",
                dependencies: [nefRender.asDependency],
                path: "project/Component/NefMarkdown")
        
    }
    static var nefJekyll: Target {
        .target(name: "NefJekyll",
                dependencies: [nefRender.asDependency],
                path: "project/Component/NefJekyll")
    }
    
    static var nefCarbon: Target {
        .target(name: "NefCarbon",
                dependencies: [nefRender.asDependency],
                path: "project/Component/NefCarbon")
    }
    
    static var nefCompiler: Target {
        .target(name: "NefCompiler",
                dependencies: [nefRender.asDependency],
                path: "project/Component/NefCompiler")
    }
    
    static var nefClean: Target {
        .target(name: "NefClean",
                dependencies: [nefCommon.asDependency],
                path: "project/Component/NefClean")
    }
    
    static var nefPlayground: Target {
        .target(name: "NefPlayground",
                dependencies: [nefCommon.asDependency],
                path: "project/Component/NefPlayground")
    }
    
    static var nefPlaygroundBook: Target {
        .target(name: "NefSwiftPlayground",
                dependencies: [nefCommon.asDependency],
                path: "project/Component/NefSwiftPlayground")
    }
}

extension Target {
    static var nef: Target {
        #if os(Linux)
        return .target(name: "nef",
                       dependencies: [.swiftLine] + Target.modules.map { $0.asDependency },
                       path: "project/Component/nef",
                       exclude: ["CleanAPI.swift",
                                 "CompilerAPI.swift",
                                 "CarbonAPI.swift",
                                 "PlaygroundAPI.swift",
                                 "Instances/MacCompilerShell.swift",
                                 "Instances/MacNefPlaygroundSystem.swift"])
        #else
        return .target(name: "nef",
                       dependencies: [.swiftLine] + Target.modules.map { $0.asDependency },
                       path: "project/Component/nef")
        #endif
    }
}

// MARK: - Tests
extension Target {
    static var tests: [Target] {
        [
            .coreTests,
        ]
    }
    
    static var coreTests: Target {
        .testTarget(name: "CoreTests",
                    dependencies: [Target.nefCore.asDependency],
                    path: "project/Tests/CoreTests")
    }
}

// MARK: - UI (command-line-tool)
extension Target {
    static var ui: [Target] {
        [
            .cliKit,
            .uiMenu,
            .uiCompiler,
            .uiClean,
            .uiMarkdown,
            .uiMarkdownPage,
            .uiJekyll,
            .uiJekyllPage,
            .uiCarbon,
            .uiCarbonPage,
            .uiPlayground,
            .uiPlaygroundBook,
        ]
    }
    
    static var cliKit: Target {
        .target(name: "CLIKit",
                dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                               Target.nef.asDependency],
                path: "project/UI",
                exclude: ["Nef/main.swift",
                          "Compiler/main.swift",
                          "Clean/main.swift",
                          "Markdown/main.swift",
                          "MarkdownPage/main.swift",
                          "Jekyll/main.swift",
                          "JekyllPage/main.swift",
                          "Carbon/main.swift",
                          "CarbonPage/main.swift",
                          "Playground/main.swift",
                          "PlaygroundBook/main.swift"])
    }
    
    static var uiMenu: Target {
        .target(name: "NefMenu",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Nef",
                sources: ["main.swift"])
    }
    
    static var uiCompiler: Target {
        .target(name: "Compiler",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Compiler",
                sources: ["main.swift"])
    }
    
    static var uiClean: Target {
        .target(name: "Clean",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Clean",
                sources: ["main.swift"])
    }
    
    static var uiMarkdown: Target {
        .target(name: "Markdown",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Markdown",
                sources: ["main.swift"])
    }
    
    static var uiMarkdownPage: Target {
        .target(name: "MarkdownPage",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/MarkdownPage",
                sources: ["main.swift"])
    }
    
    static var uiJekyll: Target {
        .target(name: "Jekyll",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Jekyll",
                sources: ["main.swift"])
    }
    
    static var uiJekyllPage: Target {
        .target(name: "JekyllPage",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/JekyllPage",
                sources: ["main.swift"])
    }
    
    static var uiCarbon: Target {
        .target(name: "Carbon",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Carbon",
                sources: ["main.swift"])
    }
    
    static var uiCarbonPage: Target {
        .target(name: "CarbonPage",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/CarbonPage",
                sources: ["main.swift"])
    }
    
    static var uiPlayground: Target {
        .target(name: "Playground",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/Playground",
                sources: ["main.swift"])
    }
    
    static var uiPlaygroundBook: Target {
        .target(name: "PlaygroundBook",
                dependencies: [Target.cliKit.asDependency,
                               Target.nef.asDependency],
                path: "project/UI/PlaygroundBook",
                sources: ["main.swift"])
    }
}

// MARK: - Products
extension Product {
    static var nef: Product {
        .library(name: "nef", targets: [Target.nef.name,
                                        Target.nefModels.name])
    }
    
    static var cli: [Product] {
        [
            .executable(name: "nef-menu",            targets: [Target.uiMenu.name]),
            .executable(name: "nefc",                targets: [Target.uiCompiler.name]),
            .executable(name: "nef-clean",           targets: [Target.uiClean.name]),
            .executable(name: "nef-markdown",        targets: [Target.uiMarkdown.name]),
            .executable(name: "nef-markdown-page",   targets: [Target.uiMarkdownPage.name]),
            .executable(name: "nef-jekyll",          targets: [Target.uiJekyll.name]),
            .executable(name: "nef-jekyll-page",     targets: [Target.uiJekyllPage.name]),
            .executable(name: "nef-carbon",          targets: [Target.uiCarbon.name]),
            .executable(name: "nef-carbon-page",     targets: [Target.uiCarbonPage.name]),
            .executable(name: "nef-playground",      targets: [Target.uiPlayground.name]),
            .executable(name: "nef-playground-book", targets: [Target.uiPlaygroundBook.name]),
        ]
    }
}

// MARK: - Package
extension Package.Dependency {
    static var dependencies: [Package.Dependency] {
        #if os(Linux)
        return [
            .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0")),
            .package(url: "https://github.com/bow-swift/Swiftline.git", .exact("0.5.6")),
        ]
        #else
        return [
            .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0")),
            .package(url: "https://github.com/bow-swift/Swiftline.git", .exact("0.5.6")),
            .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.2.1")),
        ]
        #endif
    }
}

extension Target {
    static var targets: [Target] {
        #if os(Linux)
        return [
            Target.modules,
            Target.tests,
            [Target.nef],
        ].flatMap { $0 }
        #else
        return [
            Target.modules,
            Target.tests,
            Target.ui,
            [Target.nef],
        ].flatMap { $0 }
        #endif
    }
}

extension Product {
    static var products: [Product] {
        #if os(Linux)
        return [Product.nef]
        #else
        return [Product.nef] + Product.cli
        #endif
    }
}

let package = Package(
    name: "nef",
    platforms: [.macOS(.v10_14)],
    products: Product.products,
    dependencies: Package.Dependency.dependencies,
    targets: Target.targets
)
