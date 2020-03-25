// nef:begin:header
/*
 layout: docs
 title: Playground Book with 3rd-party libraries
 */
// nef:end

/*:
 ## 🔨 Playground Book with 3rd-party libraries
 
 This page describes how to create a Playground for iPad with support for 3rd-party libraries, using the Command-Line Tool and the Xcode plugin.
 
 #### Create a Swift Package
 
 First of all, you need to define a Swift Package with your dependencies. In this tutorial, we will create one with Bow as a dependency. It'll be located at `~/Desktop`.
 
 ```swift
 // swift-tools-version:5.1
 
 import PackageDescription
 
 let package = Package(
   name: "Tutorial",
   dependencies: [
     .package(url: "https://github.com/bow-swift/bow.git", from: "0.7.0"),
   ]
 )
 ```
 
 ### 1. How to create a Playground book using nef Command-Line?
 
 #### Step 1: Run nef with subcommand `ipad`
 
 ```bash
 ➜ nef ipad --name Tutorial --package  ~/Desktop/Package.swift --output ~/Desktop
 ```
 
 #### Step 2: Copy `Tutorial.playgroundbook` to your iPad
 
 You can copy the Playground Book using AirDrop, iCloud Drive or iTunes. Our recommendation is use AirDrop; it is an easy way to transfer documents to your iPad and it will be opened automatically into the Swift Playgrounds app.
 
 <p>
 <img src="/assets/airdrop.png" height="350">
 </p>
 
 #### Step 3: Open it in your iPad using `Playgrounds` app
 
 Once you copy `Tutorial.playgroundbook` to your iPad, you only need to find it and open. It'll be opened automatically using Swift Playgrounds app.
 
 <p>
 <img src="/assets/tutorial-playgroundbook.jpeg" height="150">
 </p>
 
 ### 2. How to create a Playground book using nef Xcode plugin?
 
 #### Step 1: Install `nef Plugin` from GitHub
 
 You can find the last `.dmg` release in [GitHub](https://github.com/bow-swift/nef-plugin/releases).

 Just download the installer and move `nef` to the *Applications* folder; afterwards, you need to open it and follow the instructions:
 
 <p>
 <img src="/assets/nef-plugin-install.png" height="600">
 </p>
 
 #### Step 2: Open `Package.swift` using Xcode
 
 Go to `~/Desktop` and open the `Package.swift` you created in a previous step.
 
 #### Step 3: Make `Playground Book` using nef plugin
 
 Xcode will detect it as a Swift Package; you only need to select `Editor` > `nef` > `Swift package ➜ Playground Book` to create the Playground Book.
 
 ![](/assets/package-playground-book.png)
 
 After the Playground has been created, you can continue from the second step in the previous section in order to load it into the iPad.
 
 📣 If you download [Swift Playgrounds](https://apps.apple.com/es/app/swift-playgrounds/id1496833156?mt=12) app in your macOS, you can open it and start working. Later, you can transfer the Playground Book to your iPad to continue working; even better, you can use `iCloud Drive` and share the Playground between your Mac and your iPad, keeping its state in sync.
 */
