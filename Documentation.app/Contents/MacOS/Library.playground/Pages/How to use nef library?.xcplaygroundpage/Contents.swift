// nef:begin:header
/*
 layout: docs
 title: How to use nef library?
 */
// nef:end

/*:
 ## How to install nef library?
 
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
