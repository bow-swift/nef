---
layout: docs
title: Modules
permalink: /docs/library/apis/
---

## APIs

 `nef` provides all its features as a library that you can consume in your macOS project. It enables you to build new tooling on top of nef.
 
 It gives you easy access to render Markdown files, Jekyll content and Carbon images in a functional way. Also you can compile or clean your nef Playgrounds, even make an Xcode Playground or Playground Book compatible with 3rd-party libraries.

### Playground

 Xcode Playgrounds are a friendly tool for prototyping and trying new concepts. However, they have some limitations, if you need to create playgrounds with 3rd-party libraries support or make your Xcode Playground compatible with the rest of the options.
 
 You can find more information in [Playground API docs](/api-docs/Protocols/PlaygroundAPI.html).
 
### Compile

 You can compile a nef Playground in the same way you do from Xcode Playground IDE.
 
 You can find more information in [Compile API docs](/api-docs/Protocols/CompilerAPI.html)

### Clean

 You can clean a nef Playground, for example to share it as light as possible (without any extra compilation file).
 
 You can find more information in [Clean API docs](/api-docs/Protocols/CleanAPI.html)

### Markdown

This API lets you render the content of a Playground page, or anything else that contains [**markup formatting**](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html) and code.

 You can find more information in [Markdown API docs](/api-docs/Protocols/MarkdownAPI.html).

### Jekyll

 This API lets you render content that contains markdown, code, and [**nef commands**](https://github.com/bow-swift/nef#-generating-markdown-files-for-jekyll) to create a verified static website or blog.

 You can find more information in [Jekyll API docs](/api-docs/Protocols/JekyllAPI.html).

### Carbon

 You can share some Swift snippets as images using this API that integrates with Carbon. nef lets you render Carbon images given a configuration (including code to render and style)

 You can find more information in [Carbon API docs](/api-docs/Protocols/CarbonAPI.html).

### Playground Book

 Swift Playgrounds is a useful app that makes possible to write Swift code on an iPad. This API lets you create a Playground Book with external dependencies from a Swift Package specification.
 
 You can find more information in [Playground Book API docs](/api-docs/Protocols/SwiftPlaygroundAPI.html).

