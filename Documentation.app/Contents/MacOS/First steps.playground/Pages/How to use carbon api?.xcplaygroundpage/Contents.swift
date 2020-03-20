// nef:begin:header
/*
 layout: docs
 title: How to use carbon api?
 */
// nef:end

/*:
 
 ## How to use carbon library?

 In this section, we will see how we can use the `Carbon API`.
 
 Firstly, you need to import nef library in your project.
 > If you need to know how to add nef dependency to your macOS project, read [How to use nef library?](/docs/library/how-to-use-nef-library-/) section.
 
 ```swift
 import nef
 ```
 
 Now, you can create a carbon style to apply to our code, for the generated snippet.
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

 We could render a carbon image using this configuration and our code, invoking the next carbon API
 ```swift
 let io: EnvIO<nef.Console, Error, Data> = nef.Carbon.render(code: code, style: style)
 ```

 You will receive an [**EnvIO**](https://bow-swift.io/docs/effects/suspending-side-effects/); it lets you suspend the execution of the sides effects, in the example to create the Carbon image. That way, we could combine and compose with other operations. It is powerful!

 When we want to execute it, and get the generated `Image`, we only need to invoke an `unsafe` operation:

 ```swift
 let either = io.unsafeRunSyncEither()
 _ = either.map { (image: Data) in
     // TODO: work with the image
 }^.mapLeft { error in
     // TODO: handle error, in case something goes wrong
 }
 ```

 &nbsp;

 In the output path, you can find the result:

  ![Example: use of nef library](/assets/nef-library-example.png)

 */
