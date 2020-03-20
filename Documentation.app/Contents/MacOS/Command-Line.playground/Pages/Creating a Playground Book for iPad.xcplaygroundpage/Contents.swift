// nef:begin:header
/*
 layout: docs
 title: Creating a Playground Book for iPad
 */
// nef:end

/*:
 ## 📲 Creating a Playground Book for iPad
 
 Swift Playgrounds is a revolutionary app that makes possible to write Swift code on an iPad. Starting from Swift Playgrounds 3.x, the app has added a new feature: [UserModules](https://developer.apple.com/documentation/swift_playgrounds/structuring_content_for_swift_playgrounds/using_modules_to_share_code_in_a_playground_book); it lets you include Swift code and make it available across multiple chapters, like modules.
 
 nef takes advantage of these new possibilities, together with advancements in Swift Package Manager, to build a Playground Book with external dependencies from a Swift Package specification.
 
 Given a `Package.swift` like the next one:
 ```swift
 // swift-tools-version:5.0
 
 import PackageDescription
 
 let package = Package(
   name: "BowProject",
   dependencies: [
     .package(url: "https://github.com/bow-swift/bow.git", from: "0.7.0"),
   ]
 )
 ```
 
 You can run the following command:
 
 ```bash
 ➜ nef ipad --name PlaygroundName --package Package.swift --output ~/Desktop
 ```
 
 It will create a Playground Book (named `PlaygroundName`) with support for the external dependencies, and save it in `~/Desktop`
 
 Options:
 - `--name`: the name for the Playground Book to build.
 - `--package`: path to the Swift Package specification.
 - `--output`: path where the resulting Playground Book will be generated.
 
 */
