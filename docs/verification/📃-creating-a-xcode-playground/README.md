---
layout: docs
permalink: /docs/verification/📃-creating-a-xcode-playground/
---

 Xcode Playgrounds are a nice tool for prototyping and trying new concepts. However, third party libraries support is a bit cumbersome to add. One of the goals of `nef` is to make easier the creation of a Xcode Playground with support for one or more libraries.
 
 By default, `nef` can create a Xcode Playground with support for [Bow](http://bow-swift.io), the Functional Programming companion library for Swift.
 
 ```bash
 ➜ nef playground
 ```

### Command for creating a Xcode Playground
 You can use the following option to specify the name for the Xcode project that you are creating.
 
 ```bash
 ➜ nef playground --name LatestBowProject
 ```
 
 It will create an Xcode project with support for the latest available version of Bow, named `BowPlayground`. If you open this Xcode project, you will have a Xcode Playground where you can import Bow or any of its modules, and start trying some of its features.
 
 &nbsp;
 
 Besides this, you can select any different `Bow` version or branch, even a third-party dependency.
 
 > Note: The next three options are mutually exclusive.
 
 - `--bow-version <x.y.z>`: Specify the version of Bow that you want to use in the project. This option lets you test an old version of the library in a Xcode Playground. Example:
 
 ```bash
 ➜ nef playground --name OldBowProject --bow-version 0.3.0
 ```
 
##
 
 - `--bow-branch <branch-name>`: Specify the branch of Bow that you want to use in the project. This option lets you test features of Bow that are still in development in a branch that has not been merged or released yet. Example:
 
 ```bash
 ➜ nef playground --name BranchBowProject --bow-branch master
 ```
 
##
 
 - `--podfile <Podfile>`: Specify a Podfile with your own dependencies. This option lets you create a Playground with support for other libraries. Create a `Podfile` listing your dependencies and pass it to `nef`. Example:
 
 Your `Podfile`, located in `./folder/dependencies`:
 
 ```ruby
 target 'MyPodsProject' do
 platform :osx, '10.14'
 use_frameworks!
 
 pod 'Bow', '~> 0.3.0'
 end
 ```
 
 ```bash
 ➜ nef playground --name MyPodsProject --podfile ./folder/dependencies/Podfile
 ```
