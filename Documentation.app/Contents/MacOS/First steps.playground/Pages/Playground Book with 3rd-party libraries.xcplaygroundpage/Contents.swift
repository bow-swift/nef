// nef:begin:header
/*
 layout: docs
 title: Playground Book with 3rd-party libraries
 */
// nef:end

/*:
 ## 🔨 Playground Book with 3rd-party libraries
 
 As you read in `Getting started` section, you can use nef in different forms. Accordingly, we will see how to create a Playground for iPad compatible with 3rd-party libraries, using the Command-Line Tool and the Xcode plugin.
 
 #### Create a Swift Package
 
 Before you need to define a Swift Package with your dependencies. In this tutorial, we will create one with Bow as a dependency. It'll be located at `~/Desktop` and named `Tutorial.package`.
 
 ```swift
 // swift-tools-version:5.1
 
 import PackageDescription
 
 let package = Package(
   name: "Tutorial",
   dependencies: [
     .package(url: "https://github.com/bow-swift/bow.git", from: "0.7.0"),
   ]
 )
 ```
 
 ### 1. How to create a Playground book using nef Command-Line?
 
 ### 2. How to create a Playground book using nef Xcode plugin?
 
 */
