// nef:begin:header
/*
 layout: docs
 title: How to use carbon api?
 */
// nef:end

/*:
 
 ## How to use carbon library?

 In this section, we will see how we can use the `carbon API`

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
