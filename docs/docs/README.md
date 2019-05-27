---
layout: docs
title: Nef
permalink: /docs/
---

<p align="center">
<img alt="Nef" src="https://raw.githubusercontent.com/bow-swift/nef/develop/assets/header-nef.png" style='width:100%; height:auto;max-width:1080px'>
</p>

<p align="center">
<a href="https://travis-ci.org/bow-swift/nef">
<img src="https://travis-ci.org/bow-swift/nef.svg?branch=develop">
</a>
<a href="https://github.com/bow-swift/nef">
<img src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS-orange.svg" alt="Platforms">
</a>
<a href="https://gitter.im/bowswift/bow">
<img src="https://img.shields.io/badge/gitter-nef-blueviolet.svg" alt="Gitter">
</a>
</p>

# nef

`nef`, short for [Nefertiti](https://en.wikipedia.org/wiki/Nefertiti), mother of Ankhesenamun, is a command line tool to ease the creation of documentation in the form of Swift Playgrounds. It provides compile-time verification of documentation and exports it in Markdown format that can be consumed by [Jekyll](https://jekyllrb.com/) to generate websites.

`nef` is inspired by [ΛNK](https://github.com/arrow-kt/ank) for Kotlin and [tut](https://github.com/tpolecat/tut) for Scala.

## 📥 Installation

`nef` can be installed using [Homebrew](https://brew.sh). `nef` needs Xcode and [Cocoapods](https://cocoapods.org) as dependencies. You can run the following command to install `nef`:

```bash
brew tap bow-swift/nef
brew install nef
```

It will warn you if there is a missing dependency and provide guidance to install it.

## 🌟 Features

`nef` highlights the following features:

- Eases the creation of Swift Playgrounds with support for third party libraries.
- Compiles Swift Playgrounds with support for third party libraries from the command line.
- Generates Markdown files that can be consumed from Jekyll to create a microsite.

### 📃 Creating a Swift Playground

Swift Playgrounds are a nice tool for prototyping and trying new concepts. However, third party libraries support is a bit cumbersome to add. One of the goals of `nef` is to make easier the creation of a Swift Playground with support for one or more libraries.

By default, `nef` can create a Swift Playground with support for [Bow](http://bow-swift.io), the Functional Programming companion library for Swift. You can run the following command:

```bash
nef playground
```

It will create an Xcode project with support for the latest available version of Bow, named `BowPlayground`. If you open this Xcode project, you will have a Swift Playground where you can import Bow or any of its modules, and start trying some of its features.

> Note: You may need to build the project before, in order to be able to use the dependencies in the playground.

Besides this, you can use the following options with this command:

- `--name <project>`: Specify the name for the Xcode project that you are creating. Example:

```bash
nef playground --name LatestBowProject
```

- `--bow-version <x.y.z>`: Specify the version of Bow that you want to use in the project. This option lets you test an old version of the library in a Swift Playground. Example:

```bash
nef playground --name OldBowProject --bow-version 0.3.0
```

- `--bow-branch <branch-name>`: Specify the branch of Bow that you want to use in the project. This option lets you test features of Bow that are still in development in a branch that has not been merged or released yet. Example:

```bash
nef playground --name BranchBowProject --bow-branch master
```

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
nef playground --name MyPodsProject --podfile ./folder/dependencies/Podfile
```

The last three options are mutually exclusive.

### ⚙️ Compiling a Swift Playground

Xcode lets you check for correctness of your Swift Playground and run it. However, compiling a Swift Playground from the command line is not so easy when it has dependencies on third party libraries. This is particularly useful in Continuous Integration, when you want to verify that your playgrounds are not broken when the libraries you depend on are updated. `nef` has an option to compile Swift Playgrounds in an Xcode project with dependencies. To do this, you can run the following command:

```bash
nef compile <path>
```

Where `<path>` is the path to the folder where the project and playgrounds are located. You can also clean the result of the compilation:

```bash
nef clean <path>
```

### 🖥 Generating Markdown files for Jekyll

Swift Playgrounds let you write comments in Markdown format using the symbols `//:` for single line comments, or `/*: */` for multiline comments. Inside this comments, you can use any Markdown syntax; an exmaple:

```swift
/*:
 # This is a heading 1

 This is regular text. *This is bold text*. [This is a link](http://bow-swift.io).
 */
protocol MyProtocol {}

//: ## This is a single line heading 2
```

This makes Swift Playgrounds very suitable to write documentation with compilable examples. Leveraging this, `nef` can create Markdown files that can be consumed from Jekyll to generate a microsite. The command to do this is:

```bash
nef jekyll --project <path-to-input> --output <path-to-output> --main-page <path-to-index>
```

Options:

- `--project`: Path to the folder containing the Xcode project with Swift Playgrounds.
- `--output`: Path where the resulting Markdown files will be generated.
- `--main-page`: Optional. Path to a `README.md` file to be used as the index page of the generated microsite.

`nef` finds all the Swift Playgrounds in an Xcode project. Each playground is considered as a section in the generated microsite structure. For each page in a playground, an entry in the corresponding section is created. The page is transformed from Swift to Markdown using the syntax described above. As a result, a directory structure matching the Xcode project structure is generated, together with a `sidebar.yml` that can be used as a menu in Jekyll.

`nef` adds some commands to modify the Markdown transformation process. All `nef` commands are included as Swift comments. They begin with `// nef:begin:` and end with `// nef:end`. The supported commands are:

- `header`: It lets you add metadata to a playground page to be consumed by Jekyll. You must provide the layout that this page will use in Jekyll. The rest of attributes are optional and you may include any of them according to your Jekyll configuration. `nef` will take care of the permalinks as well. Example (at the beginning of the playground page):

```swift
// nef:begin:header
/*
  layout: docs
*/
// nef:end
```

- `hidden`: It lets you hide a portion of your playground in the output Markdown file. It is useful to hide imports or supporting utility code to make an example work. Example:

```swift
// nef:begin:hidden
import Bow // This will be hidden in the Markdown file
// nef:end

struct Person {} // This will be present in the Markdown file
```

## ❤️ Contributing to the project

You can contribute in different ways to make `nef` better:

- File an issue if you encounter a bug or malfunction in `nef`.
- Suggest a new use case or feature for `nef`.
- Open a Pull Request fixing a problem or adding new functionality.
- Discuss with us in the [Gitter channel for Bow](https://gitter.im/bowswift/bow) about all the above.

# ⚖️ License

    Copyright (C) 2019 The nef Authors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
