// nef:begin:header
/*
 layout: docs
 title: How to export my snippets
 */
// nef:end

// nef:begin:hidden
import Bow
Nef.Playground.needsIndefiniteExecution(false)
// nef:end


/*:
 ## How to export my snippets?

In this tutorial, we assume you do not have any project, and we will follow up from the beginning. If you have a current project, you can jump straight to third step.

 ### 1. Create a new `nef` project

 You will need a Xcode Playground created by `nef`. Therefore, you can start to create a new one with this command:

 ```bash
 ➜ nef playground --name TutorialCarbon
 ```

  ![](/assets/nef-playground.png)
 */

/*:
 &nbsp;
 ### 2. Add content to Xcode Playground

 Great! Open `TutorialCarbon.app` playground. It is an easy view where to see the future Playgrounds you will be creating and their pages.

 ![](/assets/nef-playground-view.png)

 Now we will add some content to our Xcode Playground. Open the associated `page` and write:
 */
 let example = "This is my first snippet"
 print("\(example) created by nef!")

 // This is my first snippet created by nef!
/*:
 &nbsp;
 ### 3. Generate code snippets

 Open a terminal and go to your `nef` project, in our case to `TutorialCarbon` and type

 ```bash
 ➜ nef carbon --project . --output ~/Desktop/snippets
 ```

  ![](/assets/nef-tutorial-carbon-defaultsnippet.png)

 But let's not stop here, we can customize the output! Running the following command we will customize the `background color` to ![#d54048](https://placehold.it/15/d54048/000000?text=+) bow, `hide the number of lines` and set the export file to `size 3`

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
