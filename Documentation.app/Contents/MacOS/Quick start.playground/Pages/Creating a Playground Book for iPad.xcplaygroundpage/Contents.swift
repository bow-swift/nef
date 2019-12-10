// nef:begin:header
/*
 layout: docs
 */
// nef:end

/*:
Swift Playgrounds is a revolutionary app that makes possible to write Swift code on an iPad. In the latest updates, Swift Playgrounds 3.x has added a new feature: [UserModules](https://developer.apple.com/documentation/swift_playgrounds/structuring_content_for_swift_playgrounds/using_modules_to_share_code_in_a_playground_book); it lets you include swift code and make it available across multiple chapters like modules.

nef takes advantage of these new possibilities and advancements in Swift Package Manager to build a Playground Book with external dependencies from a Swift Package specification.

```bash
➜ nef ipad --name PlaygroundName --package Package.swift --output ~/Desktop
```
 
 It will create a Playground Book (`PlaygroundName`) with support for the external dependencies defined in `Package.swift` and save it in `~/Desktop`

 Options:
 - `--name`: the name for the Playground Book to build.
 - `--package`: path to the Swift Package specification.
 - `--output`: path where the resulting Playground Book will be generated.
 
 */
