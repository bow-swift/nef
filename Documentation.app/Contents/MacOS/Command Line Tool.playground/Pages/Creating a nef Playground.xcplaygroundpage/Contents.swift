// nef:begin:header
/*
 layout: docs
 title: Creating a nef Playground
 */
// nef:end

/*:
 ## 📃 Creating a nef Playground

 Xcode Playgrounds are a nice tool for prototyping and trying new concepts. However, third party libraries support is a bit cumbersome to add. One of the goals of `nef` is to make the creation of an Xcode Playground easier with support for one or more libraries.

 By default, `nef` can create an Xcode Playground with support for [Bow](http://bow-swift.io), the Functional Programming companion library for Swift.

 ```bash
 ➜ nef playground
 ```

 <p align="center">
 <img src="/assets/nef-playground.png">
 </p>

 And you can use the following option to specify the name for the `nef Playground` that you are creating:

 ```bash
 ➜ nef playground --output ~/Desktop --name LatestBowProject
 ```

 It will create an Xcode project with support for the latest available version of Bow, named `LatestBowProject` in your `~/Desktop`. If you open this `nef playground`, you will find an Xcode Playground where you can import Bow or any of its modules, and start trying some of its features.

 By default, `nef playground` will be created for iOS platform. If you need to change it, you can use the `--platform` option.

 ```bash
 ➜ nef playground --platform osx
 ```

 If you need to take advantage of nef in your Xcode Playgrounds, you can transform your Xcode Playground into a nef Playground using the following command:

 ```bash
 ➜ nef playground --playground <Xcode Playground>
 ```

 Where `<Xcode Playground>` is the path to your Xcode Playground.

 ### Options
 
 You can create a nef Playground compatible with any different Bow version, branch or commit; even third-party dependencies

 > Note: The next options are mutually exclusive.

 &nbsp;
 
 - `--bow-version <x.y.z>`: Specify the version of Bow that you want to use in the project. This option lets you test an old version of the library in an Xcode Playground. Example:

 ```bash
 ➜ nef playground --name OldBowProject --bow-version 0.7.0
 ```

 &nbsp;

 - `--bow-branch <branch name>`: Specify the branch of Bow that you want to use in the project. This option lets you test features of Bow that are still in development in a branch that has not been merged or released yet. Example:

 ```bash
 ➜ nef playground --name BranchBowProject --bow-branch master
 ```

 &nbsp;

 - `--bow-commit <commit hash>`: Specify the commit hash of Bow that you want to use in the project. This option lets you test features of Bow exactly at the moment you need, released or not. Example:

 ```bash
 ➜ nef playground --name CommitBowProject --bow-commit e70c739067be1f5700f8b692523e1bb8931c7236
 ```

 &nbsp;

 - `--podfile <podfile>`: Specify a **Podfile** with your own dependencies. This option lets you create a Playground with support for other libraries. Create a `Podfile` listing your dependencies and pass it to `nef`. Example:

 Your `Podfile`, located in `./folder/dependencies`:

 ```ruby
 target 'MyPodsProject' do
   platform :osx, '10.15'
   use_frameworks!

   pod 'Bow', '~> 0.7.0'
 end
 ```

 ```bash
 ➜ nef playground --name MyPodsProject --podfile ./folder/dependencies/Podfile
 ```

 &nbsp;

 - `--cartfile <cartfile>`: Specify a **Cartfile** with your dependencies. Create a `Cartfile` listing your dependencies and pass it to `nef`. Example:

 Your `Cartfile`, located in `./folder/dependencies`:

 ```ruby
 github "bow-swift/Bow"
 ```

 ```bash
 ➜ nef playground --name MyCarthageProject --cartfile ./folder/dependencies/Cartfile
 ```
 */
