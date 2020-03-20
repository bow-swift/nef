// nef:begin:header
/*
 layout: docs
 title: Exporting Carbon code snippets
 */
// nef:end

// nef:begin:hidden
import Bow
Nef.Playground.needsIndefiniteExecution(false)
// nef:end

/*:
 ## 🌁 Exporting Carbon code snippets
 
Xcode Playgrounds are a great tool for prototyping and trying new concepts. Oftentimes we want to share some Swift snippets; for this, `Carbon` is a cool tool, and `nef` integrates seamlessly with it. You can take your nef Playground, write several pieces of code and keep it verified. Later you can export all your code snippets, with the following command:
 
 ```bash
 ➜ nef carbon --project <nef playground> --output <path>
 ```
 
 Options:
 
 - `--project`: Path to nef Playground.
 - `--output`: Path where the resulting Carbon snippets will be generated.
 
 &nbsp;
 */

/*:
 You can customize the output with the next commands
 
 <table>
 <tr>
 <th width="14%" align="center">Command</th>
 <th width="20%">Description</th>
 <th width="18%" align="center">Format</th>
 <th>Options</th>
 <th width="5%" align="center">Default</th>
 </tr>
 <tr>
 <td align="center"><code>--background</code></td>
 <td>Background color applied to image</td>
 <td>hexadecimal <code>#AABBCC</code>, <code>#AABBCCDD</code> or predefined colors</td>
 <td>
 <img src="https://placehold.it/15/8c44ff/000000?text=+"> <code> nef </code>
 <img src="https://placehold.it/15/d54048/000000?text=+"> <code> bow </code>
 <img src="https://placehold.it/15/ffffff/000000?text=+"> <code> white </code>
 <img src="https://placehold.it/15/6ef0a7/000000?text=+"> <code> green </code>
 <img src="https://placehold.it/15/42c5ff/000000?text=+"> <code> blue </code>
 <img src="https://placehold.it/15/ffed75/000000?text=+"> <code> yellow </code>
 <img src="https://placehold.it/15/ff9f46/000000?text=+"> <code> orange </code>
 </td>
 <td align="center"><code>nef</code></td>
 </tr>
 <tr>
 <td align="center"><code>--theme</code></td>
 <td>Carbon's theme to be applied</td>
 <td align="center">String</td>
 <td><code>cobalt</code>
 <code>blackboard</code>
 <code>dracula</code>
 <code>duotone</code>
 <code>hopscotch</code>
 <code>lucario</code>
 <code>material</code>
 <code>monokai</code>
 <code>nord</code>
 <code>oceanicNext</code>
 <code>oneDark</code>
 <code>panda</code>
 <code>paraiso</code>
 <code>seti</code>
 <code>purple</code>
 <code>solarized</code>
 <code>tomorrow</code>
 <code>twilight</code>
 <code>verminal</code>
 <code>vscode</code>
 <code>zenburn</code></td>
 <td align="center"><code>dracula</code></td>
 </tr>
 <tr>
 <td align="center"><code>--size</code></td>
 <td>Export file dimensions</td>
 <td align="center">Number</td>
 <td align="center">[<code>1</code>, <code>5</code>]</td>
 <td align="center"><code>2</code></td>
 </tr>
 <tr>
 <td align="center"><code>--font</code></td>
 <td>Font type</td>
 <td align="center">String</td>
 <td>
 <code>firaCode</code>
 <code>hack</code>
 <code>inconsolata</code>
 <code>iosevka</code>
 <code>monoid</code>
 <code>anonymous</code>
 <code>sourceCodePro</code>
 <code>darkMono</code>
 <code>droidMono</code>
 <code>fantasqueMono</code>
 <code>ibmPlexMono</code>
 <code>spaceMono</code>
 <code>ubuntuMono</code>
 </td>
 <td align="center"><code>firaCode</code></td>
 </tr>
 <tr>
 <td align="center"><code>--lines</code></td>
 <td>shows/hides number of lines in code snippet</td>
 <td align="center">Bool</td>
 <td><code>true</code> <code>false</code></td>
 <td align="center"><code>true</code></td>
 </tr>
 <tr>
 <td align="center"><code>--watermark</code></td>
 <td>shows/hides watermark in code snippet</td>
 <td align="center">Bool</td>
 <td><code>true</code> <code>false</code></td>
 <td align="center"><code>true</code></td>
 </tr>
 </table>
 */

/*:
 You can find an example of use in the section [How to export my snippets?](/docs/first-steps/how-to-export-my-snippets-/)
 */
