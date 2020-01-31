// nef:begin:header
/*
 layout: docs
 title: How to use nef library
 */
// nef:end

/*:
 ## How to use `nef` library?

 As you know, from Xcode 11, you can integrate package dependencies using Swift Package Manager (SPM) to share code between projects or even use third-party libraries. You can read more about it in Apple's article [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

 Starting on `nef` [version 0.4](https://github.com/bow-swift/nef/releases/tag/0.4.0), we have modularized the core so that you can use nef as in library as in your macOS projects. Taking advantage of the integration of SPM in Xcode, you can easily import `nef` in your project.

 Just choose as package repository `https://github.com/bow-swift/nef.git` and Xcode will do the rest.

 ![Add nef library to Xcode as a dependency](/assets/nef-xcode-library.png)

 Once Xcode resolves the dependencies, you can import wherever you want, as a native framework:
 ```swift
 import nef
 ```
 That's all! The power of nef runs into your project. Cool!
 */

/*:
 ## API

 `nef` library provides several utilities to work with `Markdown`, `Jekyll` and `Carbon`. It enables easy access to render Markdown files, Jekyll content and Carbon images in a functional way.

 ### Markdown

If you need to render the content of a Playground page, or anything else that combine [**markup formatting**](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html) and code.

 ```swift
 nef.Markdown.render(content: String, toFile file: URL) -> IO<nef.Error, URL>
 ```

 ### Jekyll

 When you need to render content that combines Markdown, code, and [**nef commands**](https://github.com/bow-swift/nef#-generating-markdown-files-for-jekyll) with the Jekyll style.

 ```swift
 nef.Jekyll.render(content: String, toFile file: URL, permalink: String) -> IO<nef.Error, URL>
 ```

 ### Carbon

 nef lets you render Carbon images given a CarbonModel; it is the configuration with the code and style.

 ```swift
 nef.Carbon.render(carbon: CarbonModel, toFile file: URL) -> IO<nef.Error, URL>
 ```


 You can find other helpers for drawing `Views` with a Carbon style.

 ```swift
 nef.Carbon.view(with configuration: CarbonModel) -> CarbonView
 nef.Carbon.request(with configuration: CarbonModel) -> URLRequest
 ```

 */

/*:
 ## Usage

 In this section, we will see how we can use the nef API. As an example, we will take advantage of the `Carbon API`.

 Firstly, we need to create a model with Carbon configuration and the style.
 ```swift
 let model = CarbonModel(code: """
                               import nef
                               let library = 'nef library is super cool!'
                               """,
                         style: CarbonStyle(background: .bow,
                                            theme: .dracula,
                                            size: .x1,
                                            fontType: .firaCode,
                                            lineNumbers: true, watermark: true))
 ```

 We could render a carbon image from this configuration
 ```swift
 let io = nef.Carbon.render(carbon: model, toFile: output)
 ```

 You will receive an [**IO**](https://bow-swift.io/docs/effects/suspending-side-effects/); it lets you suspend the execution of the sides effects, in the example to create the Carbon image. That way, we could combine and compose with other operations. It is powerful!

 When we want to execute it, we only need to invoke an `unsafe` operation:

 ```swift
 let either = io.unsafeRunSyncEither()
 either.map { url in
    // TODO
 }.mapLeft { error in
    // TODO
 }
 ```

 &nbsp;

 In the output path, you can find the result:

  ![Example: use of nef library](/assets/nef-library-example.png)

 */
