---
layout: docs
permalink: /docs/integration/🖥-generating-markdown-files-for-jekyll/
---

 As you can write comments in [Markdown](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html) in Swift Playgrounds, this makes very suitable to write documentation with compilable examples.
 Leveraging this, `nef` can create Markdown files that can be consumed from Jekyll to generate a microsite. The command to do this is:
 
 ```bash
 ➜ nef jekyll --project <path-to-input> --output <path-to-output> --main-page <path-to-index>
 ```
 
 Options:
 
 - `--project`: Path to the folder containing the Xcode project with Swift Playgrounds.
 - `--output`: Path where the resulting Markdown files will be generated.
 - `--main-page`: Optional. Path to a `README.md` file to be used as the index page of the generated microsite.
 
 &nbsp;
 
 `nef` finds all the Swift Playgrounds in an Xcode project. Each playground is considered as a section in the generated microsite structure. For each page in a playground, an entry in the corresponding section is created. The page is transformed from Swift to Markdown using the syntax described above. As a result, a directory structure matching the Xcode project structure is generated, together with a `sidebar.yml` that can be used as a menu in Jekyll.
 
 `nef` adds some commands to modify the Markdown transformation process. All `nef` commands are included as Swift comments. They begin with `// nef:begin:` and end with `// nef:end`. The supported commands are:
 
 - `header`: It lets you add metadata to a playground page to be consumed by Jekyll. You must provide the layout that this page will use in Jekyll. The rest of attributes are optional and you may include any of them according to your Jekyll configuration. `nef` will take care of the permalinks as well. Example (at the beginning of the playground page):
 
 ```swift
 /&#42;
 layout: docs
 &#42;/
 ```
 
 - `hidden`: It lets you hide a portion of your playground in the output Markdown file. It is useful to hide imports or supporting utility code to make an example work. Example:
 
 ```swift
 import Bow // This will be hidden in the Markdown file
 
 struct Person {} // This will be present in the Markdown file
 ```
