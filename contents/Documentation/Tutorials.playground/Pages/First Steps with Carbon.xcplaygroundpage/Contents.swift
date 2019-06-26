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
 ## How to export my snippets?
 
 For this tutorial, we suppose you do not have any project, and we will follow up from the beginning. If you have a current project, you can go to third step.
 
 ### 1. Create a new `nef` project
 
 You will need a Xcode Playground created by `nef`. Therefore, you can start to create a new one with this command:
 
 ```bash
 ➜ nef playground --name TutorialCarbon
 ```
 */


/*:
 &nbsp;
 ### 2. Add content to Xcode Playground
 
 Great! Go to `TutorialCarbon` and open the `xcworkspace` associate. It is an easy view where to see the futures Playgrounds you are creating and its pages.
 
 ![](/assets/nef-playground-view.png)
 
 Now we will add some content to our Xcode Playground. Open the associate `page` and write:
 
 ```swift
 let example = "This is my first snippet"
 print("\(example) created by nef!")
 
 // This is my first snippet created by nef!
 ```
 */


/*:
 &nbsp;
 ### 3. Generates code snippets
 
 Open a terminal and go to your `nef` project, in our case to `TutorialCarbon` and type
 
 ```bash
 ➜ nef carbon --project . --output ~/Desktop/snippets
 ```
 
  ![](/assets/nef-tutorial-carbon-defaultsnippet.png)
 
 But let's not stop here, we can customize the output! Running the following command we will customize the `background color` to ![#d54048](https://placehold.it/15/d54048/000000?text=+) bow, `hides the number of lines` and set the export file to `size 3`
 
 ```bash
 ➜ nef carbon --project . --output ~/Desktop/snippets --background bow --size 3 --lines false
 ```
 
 ![](/assets/nef-tutorial-carbon-customsnippet.png)
 
 */


/*:
 &nbsp;
 ### 4. Customize your snippets!
 Go to [Carbon Integration](/docs/integration/carbon/) section for reading more about these and another parameters you can use :)
 */
