// nef:begin:header
/*
 layout: docs
 title: How to use Carbon API?
 */
// nef:end

/*:
 
 ## How to use Carbon API?

 In this section, we will see how we can use the `Carbon API`.
 
 Firstly, you need to import nef library in your project.
 > If you need to know how to add nef dependency to your macOS project, read [How to use nef as a library?](/docs/library/how-to-use-nef-as-a-library-/) section.
 
 ```swift
 import nef
 ```
 
 Now, you can create a Carbon style to apply to our code, for the generated snippet.
 ```swift
 let code =  """
             import nef
             let library = 'nef library is super cool!'
             """
 
 let style = CarbonStyle(background: .bow,
                         theme: .dracula,
                         size: .x1,
                         fontType: .firaCode,
                         lineNumbers: true, watermark: true)
 ```

 We could render a Carbon image using this configuration and our code, invoking the next Carbon API
 ```swift
 let io: EnvIO<nef.Console, nef.Error, Data> = nef.Carbon.render(code: code, style: style)
 ```

 You will receive an [**EnvIO**](https://bow-swift.io/docs/effects/suspending-side-effects/), which lets you suspend the execution of the side effects; in the example, to create the Carbon image. That way, we could combine and compose it with other operations.

 We can extract the associated image and work with them, for example, if we have a method to transform this Data to NSImage, we can obtain an `IO<nef.Error, NSImage>` as follows:

 ```swift
 func extractImage(from data: Data) -> IO<nef.Error, NSImage> { ... }
 
 let imageIO: IO<nef.Error, NSImage> = io.provide(console).flatMap(extractImage)^
 ```

 You can write the `NSImage` or draw in your view, and the appearance will be

  ![Example: use of nef library](/assets/nef-library-example.png)

 */
