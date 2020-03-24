// nef:begin:header
/*
 layout: docs
 title: Xcode Playground → nef Playground
 */
// nef:end

/*:
 ## Xcode Playground ⇢ nef Playground
 
 I assume you have an Xcode Playground and you want to take advantage of `nef Playground` features:
 
 - 🎉 Adds support for __third party libraries__.
 
 - 🖥 Enables to __compile__ using command-line (out-of-the-box Apple IDE).
 
 + 🗞 Renders into __markdown__ files, __Jekyll__ site or __Carbon__ snippets.
 
 &nbsp;
 
 Given an Xcode Playground, which name will be `MyPlayground` and it is located at `~/Desktop`
 
 1.- If your playground does not have any page, add someone, for example `Tutorial`. Your playground structure should look like:
 
 ![](/assets/myplayground.png)
 
 2.- Run nef with the option --playground:
 
 ```bash
 ➜ nef playground --playground ~/Desktop/MyPlayground.playground --name MyPlayground
 ```
 
 It'll create a `nef Playground` in your current location which name will be `MyPlayground`. You can go to the section **Command-Line** to learn more about nef Playgrounds.
 
 Using one of these options, you can change the dependency manager and its dependencies by default

 - `--podfile <podfile>` Specify a **Podfile** with your own dependencies. Create a `Podfile` listing your dependencies.

 - `--cartfile <cartfile>` Specify a **Cartfile** with your dependencies. Create a Cartfile listing your dependencies.

 > You can find more options and information in the section [Creating a nef Playground](/docs/command-line/creating-a-nef-playground/).
 
 &nbsp;
 
 ### How to make an Xcode Playground compatible with CocoaPods?
 
 Following the options seen above, we will continue the example to make our Xcode Playground compatibles with 3rd-party libraries using CocoaPods as a dependency manager.
 
 1.- Create a `Podfile` listing your dependencies. I'll be named `MyPodfile` and located at `~/Desktop`
 
 ```
 target 'MyPodfile' do
   platform :osx, '10.15'
   use_frameworks!

   pod 'Bow', '~> 0.7.0'
 end
 ```
 
 2.- Run nef with the options `--playground` and `--podfile`:
 ```bash
 ➜ nef playground --playground ~/Desktop/MyPlayground.playground --name MyPlayground --podfile ~/Desktop/MyPodfile
 ```
 
 > Currently, nef is compatible with CocoaPods and Carthage. In the future, when Apple fixes a known issues in Swift package and Xcode ([#47668990](https://github.com/bow-swift/nef/issues/33)) it'll also be compatible with SPM.
 */
