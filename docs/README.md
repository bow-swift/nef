---
layout: docs
title: nef
permalink: /docs/
---

# nef

short for [Nefertiti](https://en.wikipedia.org/wiki/Nefertiti), mother of Ankhesenamun, is a command line tool to ease the creation of documentation in the form of Swift Playgrounds. It provides compile-time verification of documentation and exports it in Markdown format that can be consumed by [Jekyll](https://jekyllrb.com/) to generate websites.

`nef` is inspired by [ΛNK](https://github.com/arrow-kt/ank) for Kotlin and [tut](https://github.com/tpolecat/tut) for Scala.


### Why nef?

💡 Eases the creation of Xcode Playgrounds with support for [__third party libraries__](https://github.com/bow-swift/nef#-creating-a-nef-playground).

💡 [__Compiles Xcode Playgrounds__](https://github.com/bow-swift/nef#-compiling-a-nef-playground) with support for 3rd-party libraries from the command line.

💡 Builds a [__Playground Book__](https://github.com/bow-swift/nef#-creating-a-playground-book) for iPad with external dependencies defined in a Swift Package.

💡 Generates [__Markdown__](https://github.com/bow-swift/nef#-generating-a-markdown-project) project from nef Playground.

💡 Generates Markdown files that can be consumed from [__Jekyll__](https://github.com/bow-swift/nef#-generating-markdown-files-for-jekyll) to create a microsite.

💡 Export [__Carbon__](https://github.com/bow-swift/nef#-exporting-carbon-code-snippets) code snippets for a given nef Playground.


### 📥 Installation

`nef` can be installed using [Homebrew](https://brew.sh). `nef` needs Xcode 11 (o newer), [CocoaPods](https://cocoapods.org/), and [brew](https://brew.sh/index_es) installed in your computer.

```bash
➜ brew install nef
```

> It will warn you if there is a missing dependency and will provide guidance to install it.
