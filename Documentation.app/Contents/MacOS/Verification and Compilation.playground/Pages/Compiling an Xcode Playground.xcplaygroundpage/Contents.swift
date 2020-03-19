// nef:begin:header
/*
 layout: docs
 title: Compiling an Xcode Playground
 */
// nef:end

// nef:begin:hidden
import Bow
Nef.Playground.needsIndefiniteExecution(false)
// nef:end

/*:
 ## 🔨 Compiling an Xcode Playground
 Xcode lets you check for correctness of your Xcode Playground and run it. However, compiling a Xcode Playground from the command line is not so easy when it has dependencies on third party libraries. This is particularly useful in Continuous Integration, when you want to verify that your playgrounds are not broken when the libraries you depend on are updated. `nef` has an option to compile Xcode Playgrounds in an Xcode project with dependencies. To do this, you can run the following command:

 ```bash
 ➜ nef compile <path>
 ```

 Where `<path>` is the path to the folder where the project and playgrounds are located. You can use the following option with this command:

 - `--use-cache`: Use cached dependencies if it is possible, in another case, it will download them. Example:

 ```bash
 ➜ nef compile <path> --use-cache
 ```

 You can also clean the result of the compilation:

 ```bash
 ➜ nef clean <path>
 ```
 */
