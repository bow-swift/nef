---
layout: docs
title: Getting started
permalink: /docs/quick-start/getting-started/
---

## Getting started
 `nef` is a command line tool to ease the creation of documentation in the form of Swift Playgrounds. It provides compile-time verification of documentation and exports it in Markdown format that can be consumed by [Jekyll](https://jekyllrb.com/) to generate websites.

### 💻 Installation

#### 📟 Using [Homebrew](https://github.com/bow-swift/homebrew-nef) (preferred)

 ```bash
 ➜ brew install nef
 ```

 > It will warn you if there is a missing dependency and will provide guidance to install it. nef is compatible with macOS 10.14+

 📣 You will find more information in [Command-Line](/docs/command-line/creating-a-nef-playground/) section.

 &nbsp;

#### 📦 Using [Swift Package Manager](https://developer.apple.com/documentation/xcode/creating_a_swift_package_with_xcode)

 `nef` can be consumed as a library in your **macOS project**.

 ```swift
 .package(url: "https://github.com/bow-swift/nef.git", from: "{version}")
 ```

 It is an excellent option if you want to use all nef features in your macOS app, even to build new tooling on top of nef.

 📣 You will find more information in [Library](/docs/library/how-to-use-nef-library/) section.
 
 &nbsp;

#### 🔌 Using [Xcode Editor Extension](https://github.com/bow-swift/nef-plugin)

 Some of `nef` features can be used directly in Xcode as an Extension. You can install it directly from [**App Store**](https://apps.apple.com/app/nef/id1479391704?mt=8) or downloading the last binary from the [**releases section**](https://github.com/bow-swift/nef-plugin/releases).
 
  &nbsp;
 
#### 📲 Using your [iPad](https://github.com/bow-swift/nef-editor-client)

 You can create Swift Playgrounds -together with third-party libraries- directly in your iPad using the app [**nef Playgrounds**](https://apps.apple.com/us/app/nef-playgrounds/id1511012848).

 &nbsp;

#### Using a [GitHub badge](https://github.com/bow-swift/nef-playgrounds-badge)

 You can create a [**nef badge**](badge.bow-swift.io) for your GitHub repository, and let users try your project in their iPads.

 <img src="https://raw.githubusercontent.com/bow-swift/bow-art/master/badges/nef-playgrounds-badge.svg" alt="bow Playground" style="height:20px">
 
