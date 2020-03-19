// nef:begin:header
/*
 layout: docs
 title: Compiling a nef Playground
 */
// nef:end

/*:
 ## 🔨 Compiling a nef Playground
 
 Xcode lets you check for correctness of your Xcode Playground and run it. However, Apple does not provide us commands to compile an Xcode Playground, as they do for building Xcode projects. It is particularly useful in Continuous Integration when you want to verify that your playgrounds are not broken when the libraries you depend on are updated. `nef` has an option to compile a `nef Playground`. To do this, you can run the following command:
 
 ```bash
 ➜ nef compile --project <nef playground>
 ```
 > If you need to transform your Xcode Playground into a nef Playground you can check [Creating a nef Playground](#-creating-a-nef-playground) section.
 
 Where `<nef playground>` is the path to `nef Playground` where your playgrounds are located. Also, you can use the following option with this command:
 
 - `--use-cache`: Use cached dependencies if it is possible, in another case, it will download them. Example:
 
 ```bash
 ➜ nef compile --project <nef playground> --use-cache
 ```
 
 You can also clean the result of the compilation:
 
 ```bash
 ➜ nef clean --project <nef playground>
 ```
 */
