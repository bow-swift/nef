// nef:begin:header
/*
 layout: docs
 title: How to export my snippets?
 */
// nef:end

/*:
 ## How to export my snippets?

In this tutorial, we assume you do not have any project, and we will follow up from the beginning. If you have a current project, you can jump straight to third step.

 #### Step 1: Create a new `nef` project

 You will need a `nef Playground`. Therefore, you can start to create a new one with this command:

 ```bash
 ➜ nef playground --name TutorialCarbon
 ```

  ![](/assets/nef-playground.png)
 
 Go back to [Creating a nef Playground](/docs/command-line/creating-a-nef-playground/) to read more about these and other parameters you can use.
 
 #### Step 2: Add content to nef Playground

 Great! Open `TutorialCarbon.app` playground. It is an easy view where to see the future Playgrounds you will be creating and their pages.

 ![](/assets/nef-playground-view.png)

 Now we will add some content to our Xcode Playground. Open the associated `page` and write:
 */
 let example = "This is my first snippet"
 print("\(example) created by nef!")

 // This is my first snippet created by nef!
 /*:
 
 #### Step 3: Generate code snippets

 Using your terminal we will export all code snippets using `nef` and your `nef Playground`, in our case from `TutorialCarbon`.

 ```bash
 ➜ nef carbon --project TutorialCarbon.app --output ~/Desktop/snippets
 ```

  ![](/assets/nef-tutorial-carbon-defaultsnippet.png)

 But let's not stop here, we can customize the output! Running the following command we will customize the `background color` to ![#d54048](https://placehold.it/15/d54048/000000?text=+) bow, `hide the number of lines` and set the export file to `size 3`

 ```bash
 ➜ nef carbon --project TutorialCarbon.app --output ~/Desktop/snippets --background bow --size 3 --show-lines false
 ```

 ![](/assets/nef-tutorial-carbon-customsnippet.png)

 #### Step 4: Customize your snippets
 
 Go back to [Carbon Integration](/docs/command-line/exporting-carbon-code-snippets/) to read more about these and other parameters you can use :)
 */
