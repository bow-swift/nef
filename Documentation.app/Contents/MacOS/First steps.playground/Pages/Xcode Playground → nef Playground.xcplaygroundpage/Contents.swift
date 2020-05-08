// nef:begin:header
/*
 layout: docs
 title: Xcode Playground → nef Playground
 */
// nef:end

/*:
 ## Xcode Playground ⇢ nef Playground
 
 Let's assume you already have an Xcode Playground and you want to take advantage of `nef Playground` features:
 
 - 🎉 Adds support for __third party libraries__.
 
 - 🖥 Enables __compilation__ of Playgrounds using command-line.
 
 + 🗞 Renders into __Markdown__ files, a __Jekyll__ site or __Carbon__ snippets.
 
 &nbsp;
 
 #### Step 1: Prepare your Xcode Playground
 
 Let's assume you have an Xcode Playground, named `MyPlayground` in this example, and located at `~/Desktop`.
 
 If your playground does not have any page, add some; for example, a page titled `Tutorial`. Your playground structure should look like:
 
 ![](/assets/myplayground.png)
 
 #### Step 2: Converts an Xcode Playground to nef Playground
 
 ```bash
 ➜ nef playground --playground ~/Desktop/MyPlayground.playground --name MyPlayground
 ```
 
 It'll create a `nef Playground` in your current location, named `MyPlayground`. You can go to the section **Command-Line** to learn more about nef Playgrounds.
 
 Using one of these options, you can change the dependency manager and its default dependencies:

 - `--podfile <podfile>`: Supply a **Podfile** with your own dependencies. You need to create a `Podfile` listing your dependencies.

 - `--cartfile <cartfile>`: Supply a **Cartfile** with your dependencies. You need to create a Cartfile listing your dependencies.

 > You can find more options and information in the section [Creating a nef Playground](/docs/command-line/creating-a-nef-playground/).
 
 &nbsp;
 
 ### How to make an Xcode Playground compatible with CocoaPods?
 
 Following the options seen above, we will continue the example to make our Xcode Playgrounds compatible with 3rd-party libraries using CocoaPods as a dependency manager.
 
 #### Step 1: Create a `Podfile` listing your dependencies

 It will be named `MyPodfile` and located at `~/Desktop`
 
 ```
 target 'MyPodfile' do
   platform :osx, '10.15'
   use_frameworks!

   pod 'Bow', '~> 0.8.0'
 end
 ```
 
 #### Step 2: Convert an Xcode Playground using your dependencies
 
 Run nef with the options `--playground` and `--podfile`:
 
 ```bash
 ➜ nef playground --playground ~/Desktop/MyPlayground.playground --name MyPlayground --podfile ~/Desktop/MyPodfile
 ```
 
 > Currently, nef is compatible with CocoaPods and Carthage. In the future, when Apple fixes a known issues in Swift Package Manager and Xcode ([#47668990](https://github.com/bow-swift/nef/issues/33)), it will also be compatible with SPM.
 */
