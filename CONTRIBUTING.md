# Guidelines to contribute to nef

We appreciate any contributions to help nef move forward. Note that we have a [code of conduct](CODE_OF_CONDUCT.md); please, follow it in all your interactions with the project.

## How you can help

There are several things you can do to help nef grow:

- **Report bugs and malfunctioning issues**: Use the [issue template](https://github.com/bow-swift/nef/issues/new?assignees=Maintainers&labels=&template=bug.md&title%5B%5D=Bug) for *bugs* and provide as much detail as possible to help us find the cause of the problem, reproduce it, and fix it. Please, take your time to go through the list of open issues in order to make sure they are not duplicated.
- **Suggest new features**: Use the [issue template](https://github.com/bow-swift/nef/issues/new?assignees=Maintainers&labels=&template=feature_request.md&title%5B%5D=Request) for *feature requests* to suggest a new feature or integration in the library. Do not proceed to the implementation of the new feature until it has been discussed in the issue comments. You can also join the [Gitter channel for Bow](https://gitter.im/bowswift/bow) for longer discussions.
- **Implement approved features**: After a suggested feature has been discussed and approved, you can get assigned to the corresponding issue and implement it. Contributions need to go through a code review process. Follow the instructions below for pull requests.

## Documentation

nef provides a section in its microsite where its documentation is [published](https://nef.bow-swift.io/docs/) in the form of tutorial-like articles. If you want to contribute by adding an article here, this is what you need.

### Installation

- Make sure you have last version of [nef](https://github.com/bow-swift/nef/#-using-homebrew-preferred), Xcode 11 (o newer), [CocoaPods](https://cocoapods.org/), and [brew](https://brew.sh/index_es) installed in your computer.
- Clone the repository for nef and go to the cloned folder.
- Run `nef compile --project Documentation.app` to set up the project with its dependencies.
- Open `Documentation.app`

### Adding content

If you pay attention to the project structure, you can see that it has multiple Xcode Playgrounds that mirror the side bar of [this page](https://nef.bow-swift.io/docs/). You can also see that the Playground pages for each section match the pages inside each section on the web.

- Do you want to add a new section? You just need to add a new Playground and place it in the order you want it to appear on the website.
- Do you want to add a new page? You just need to add a new page to the corresponding Playground (section).

In order to add documentation, use the standard Markdown format used in Xcode Playgrounds. For reference, you can check it out in the [official documentation from Apple](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html).


### Compiling documentation

Once you are done, you can check that your document compiles properly by moving to the root directory of the nef project and running the following command:

```bash
➜ nef compile --project Documentation.app
```

If everything is correct, your document should be ready for publication.

### Rendering content locally

If you want to check **how** your documentation will be rendered once it is published, follow the next steps in the root directory.

#### A. Rendering simple documentation (without API docs)

```bash
➜ nef jekyll --project Documentation.app --output docs --main-page Documentation.app/Jekyll/Home.md
```

- You can install the dependencies you need with:

```bash
➜ bundle install --gemfile docs/Gemfile --path vendor/bundle
```

- Once it is done, you can set up a local server with the site by running:

```
BUNDLE_GEMFILE=./docs/Gemfile bundle exec jekyll serve -s ./docs
```

- The site will be available at the URL [http://127.0.0.1:4000](http://127.0.0.1:4000). Note: syntax highlighting may not render properly if you do not generate the API reference (read B. subsection)

#### B. Rendering full documentation (including API reference)

```bash
➜ brew install sourcekitten
➜ ./scripts/gen-docs.rb
```

- You can install the dependencies you need with:

```bash
➜ bundle install --gemfile pub-dir/Gemfile --path vendor/bundle
```

- Once it is done, you can set up a local server with the site by running:

```
BUNDLE_GEMFILE=./pub-dir/Gemfile bundle exec jekyll serve -s ./pub-dir
```

- The site will be available at the URL [http://127.0.0.1:4000](http://127.0.0.1:4000)

🚨 If you need to regenerate the site after changing nef Playground `Documentation`, you only need run (and the site will be reloaded):
```bash
➜ nef jekyll --project Documentation.app --output pub-dir --main-page Documentation.app/Jekyll/Home.md
```
