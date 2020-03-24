require 'fileutils'

module Nef

  class TemplateConfigurator
    attr_reader :project_name

    def initialize(project_name)
      @project_name = project_name
    end

    def run
      clean_unuseful_files
      ConfigureNef.perform(configurator: self)
      replace_variables_in_files
      clean_template_files
      setPlaygroundApp
    end

    # private methods
    def replace_variables_in_files
      file_names = ['LICENSE']
      file_names.each do |file_name|
        if File.exist?(file_name)
            text = File.read(file_name)
            text.gsub!("${REPO_NAME}", @project_name.gsub('+', '-'))
            text.gsub!("${USER_NAME}", user_name)
            text.gsub!("${USER_EMAIL}", user_email)
            text.gsub!("${YEAR}", year)
            text.gsub!("${DATE}", date)
            File.open(file_name, "w") { |file| file.puts text }
        end
      end
    end

    def clean_unuseful_files
      [".git", ".gitignore", ".build", ".travis.yml", ".mailmap", ".github",
        "LICENSE", "README.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md",
        "assets", "bin", "configure", "contents", "docs", "project", "setup", "scripts",
        "Package.swift", "Package.resolved", "Documentation.app", "Makefile", "*.log"].each do |asset|
        `rm -rf #{asset}`
      end
    end

    def clean_template_files
      ["template"].each do |asset|
        `rm -rf #{asset}`
      end
    end

    def setPlaygroundApp
      File.rename("PROJECT.app", @project_name+".app")
    end

    # properties
    def user_name
      (ENV['GIT_COMMITTER_NAME'] || github_user_name || `git config user.name` || `<GITHUB_USERNAME>` ).strip
    end

    def github_user_name
      github_user_name = `security find-internet-password -s github.com | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'`.strip
      is_valid = github_user_name.empty? or github_user_name.include? '@'
      return is_valid ? nil : github_user_name
    end

    def user_email
      (ENV['GIT_COMMITTER_EMAIL'] || `git config user.email`).strip
    end

    def year
      Time.now.year.to_s
    end

    def date
      Time.now.strftime "%m/%d/%Y"
    end

  end
end
