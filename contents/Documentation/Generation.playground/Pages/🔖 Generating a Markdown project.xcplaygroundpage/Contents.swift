// nef:begin:header
/*
 layout: docs
 */
// nef:end

// nef:begin:hidden
import Bow
Nef.Playground.needsIndefiniteExecution(false)
// nef:end

/*:
 Swift Playgrounds let you write comments in Markdown format using the symbols `//:` for single line comments, or `/`*: ... *`/` for multiline comments. Inside this comments, you can use any Markdown syntax; an exmaple:
 
 ```swift
 /&#42;:
 ### This is a heading 1
 
 This is regular text. *This is bold text*. [This is a link](http://bow-swift.io).
  &#42;/
 protocol MyProtocol {}
 
 //: ## This is a single line heading 2
 ```
 
 It makes Swift Playgrounds the proper tool to write an article with compilable examples. The command provided by `nef` to generate the Markdown files is:
 
 ```bash
 ➜ nef markdown --project <path-to-input> --output <path-to-output>
 ```
 
 Options:
 
 - `--project`: Path to the folder containing the Xcode project with Swift Playgrounds.
 - `--output`: Path where the resulting Markdown project will be generated.
 
 */
