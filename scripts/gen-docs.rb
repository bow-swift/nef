#!/usr/bin/env ruby
require 'json'

## VERSIONED DOCS GENERATION ##

# If you want a specific version to be served as default, set this value to the
# branch/tag you want. Otherwise it will be the latest version on alphabetical order.
# If there's no tags, then `master` branch content will be served at root path.
$default_version = "0.6.0"

# If you want to build the current branch (usually `master`) and serve it,
# set the path/name in here. If you leave it empty no site will be built for it.
$current_branch_path = "next"

# This is a list to filter -out- tags we know are not valuable to generate docs
# for. If you set one tag in the default_version, you can add it here, so it's
# not generated twice. Unless you want to have the same content at two paths.
$invalid_tags = ["0.1.0", "0.1.1", "0.1.2", "0.1.3", "0.1.4", "0.1.5", "0.1.6", "0.1.7", "0.2.0", "0.2.1", "0.2.2", "0.2.3", "0.3.0", "0.3.1", "0.3.2", "0.4.0", "0.5.2"]

# This is a list to filter -in- tags. Unless it's empty, where it will be ignored.
# If you want an empty tags list in the end (for some reason ¯\_(ツ)_/¯)
# you can cancel these filterings with both lists having the same values:
# invalid_tags = ["0.1.0"], valid_tags = ["0.1.0"]
$valid_tags = []

# The path of the dir where the Jekyll source is located.
$source_dir = "docs"

# The path of the dir that will be published. Check out GitHub Pages/Travis for this.
$publishing_dir = "pub-dir"

# The path of the dir to temporarily store the different sites content.
$gen_docs_dir = "gen-docs"

# The path of the dir to temporarily store the JSON files for API sites.
$json_files_dir = "json-files"

# This a list of modules in which the Swift project is split on
$modules = ["NefModels", "nef"]

# Generate the JSON files that will be needed later.
# Modules present in the project are used to split the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def generate_json(version)
  system "echo == Generating JSON API data for #{version}"
  `mkdir -p #{$json_files_dir}/#{version}`
  $modules.each { |m| `sourcekitten doc --spm-module #{m} > #{$json_files_dir}/#{version}/#{m}.json` }
end

# Join the previously generated JSON files into one single file.
# The array of modules in the project is used to join the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def join_json(version)
  system "echo == Joining all different JSON API data for #{version}"
  joined = []
  $modules.map { |m| JSON.parse(File.read("#{$json_files_dir}/#{version}/#{m}.json")) } \
    .each { |json| joined += json }

  File.open("#{$json_files_dir}/#{version}/all.json","w") do |f|
    f.write(joined.to_json)
  end
end

# Generate the Jekyll site through nef based on the contents source.
#
# @param version [String] The version for which the nef docs site will be generated.
# @param versions_list [Array] The list of versions available to select in the whole project.
# @return [nil] nil.
def generate_nef_site(version, versions_list)
  system "echo == Generating nef site for #{version}"
  this_versions = versions_list.dup;
  this_versions[versions_list.find_index("title" => version)] = {
    "title" => version,
    "this" => true
  };
  `mkdir -p #{$source_dir}/_data`
  File.write("#{$source_dir}/_data/versions.json", JSON.pretty_generate(this_versions))
  # Removing lockfile to avoid conflict in case it differs between versions
  system "rm #{$source_dir}/Gemfile.lock"
  system "nef jekyll --project Documentation.app --output docs --main-page Documentation.app/jekyll/Home.md"
  system "JEKYLL_ENV=production BUNDLE_GEMFILE=./#{$source_dir}/Gemfile bundle exec jekyll build -s #{$source_dir} -d #{$gen_docs_dir}/#{version} -b #{version}"
  system "rm -rf #{$source_dir}/docs"
  system "ls -la #{$source_dir}"
  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Generate the Jazzy site based on previouly created JSON file.
#
# @param version [String] The version for which the Jazzy API docs site will be generated.
# @return [nil] nil.
def generate_api_site(version)
  system "echo == Generating API site for #{version}"
  # Removing lockfile to avoid conflict in case it differs between versions
  system "rm #{$source_dir}/Gemfile.lock"
  system "BUNDLE_GEMFILE=#{$source_dir}/Gemfile bundle exec jazzy -o #{$gen_docs_dir}/#{version}/api-docs --sourcekitten-sourcefile #{$json_files_dir}/#{version}/all.json --author Nef --author_url https://nef.bow-swift.io --github_url https://github.com/bow-swift/nef --module nef --root-url https://nef.bow-swift.io/#{version}/api-docs --theme docs/extra/nef-jazzy-theme"
  system "ls -la #{$source_dir}"
  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Directory initialization
`mkdir -p #{$json_files_dir}`
`mkdir -p #{$publishing_dir}`
`mkdir -p #{$gen_docs_dir}`

# Initial generic logic and dependencies for the docs site
system "echo == Installing ruby dependencies"
system "bundle install --gemfile #{$source_dir}/Gemfile --path vendor/bundle"

# Now, we generate the content available at the initial branch (master?)
# to be at $current_branch_path (/next?) path
if !$current_branch_path.to_s.empty?
  `git checkout -f #{current_branch_tag}`
  system "echo == Current branch/tag is now #{current_branch_tag}"
  system "echo == Compiling the library in #{current_branch_tag}"
  system "swift package clean"
  system "swift build"
  generate_nef_site($current_branch_path, versions)
  generate_json($current_branch_path)
  join_json($current_branch_path)
  generate_api_site($current_branch_path)
end

# Finally, we generate the docs for the default version
`git checkout -f #{$default_version}`
system "echo == Current branch/tag is now #{$default_version}"
system "echo == Compiling the library in #{current_branch_tag}"
system "swift package clean"
system "swift build"

system "echo == Generating nef site for #{$default_version}"
# Let's create the versions file for the default version
`mkdir -p #{$source_dir}/_data`
this_versions = versions.dup;
this_versions[this_versions.find_index("title" => $default_version)] = {
  "title" => $default_version,
  "this" => true
};
File.write("#{$source_dir}/_data/versions.json", JSON.pretty_generate(this_versions))

system "nef jekyll --project Documentation.app --output docs --main-page Documentation.app/jekyll/Home.md"
# The content available in the default branch will be generated by GH Pages itself
system "ls -la #{$source_dir}"

# And then, we need to generate the API docs for the default version
generate_json("#{$default_version}")
join_json("#{$default_version}")
generate_api_site("#{$default_version}")
system "ls -la #{$source_dir}"
system "ls -la #{$gen_docs_dir}/#{$default_version}"

# Now we need to move default API docs to the default publishing location too.
`mv #{$gen_docs_dir}/#{$default_version}/api-docs #{$gen_docs_dir}/`

# We also move the rest of version generated sites to its publishing destination
`mv #{$gen_docs_dir}/* #{$publishing_dir}/`

# We need to remove dependencies dir, as it's unnecessary, and it messes GH Pages
`rm -rf #{$source_dir}/vendor`

# And finally we move the source to the directory that will be published.
# Remember that this should be the same directory set in GH Pages/Travis.
`mv #{$source_dir}/* #{$publishing_dir}/`
