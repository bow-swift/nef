require 'fileutils'
require 'colored2'

module Pod
  class TemplateConfigurator

    attr_reader :pod_name, :pods_for_podfile, :prefixes, :username, :email

    def initialize(pod_name)
      @pod_name = pod_name
      @pods_for_podfile = []
      @prefixes = []
    end

    def run
      clean_unuseful_files
      ConfigureNef.perform(configurator: self)

      replace_variables_in_files
      clean_template_files
      add_pods_to_podfile
    end

    #----------------------------------------#

    def replace_variables_in_files
      file_names = [podfile_path, license_path]
      file_names.each do |file_name|
        text = File.read(file_name)
        text.gsub!("${POD_NAME}", @pod_name)
        text.gsub!("${REPO_NAME}", @pod_name.gsub('+', '-'))
        text.gsub!("${USER_NAME}", user_name)
        text.gsub!("${USER_EMAIL}", user_email)
        text.gsub!("${YEAR}", year)
        text.gsub!("${DATE}", date)
        File.open(file_name, "w") { |file| file.puts text }
      end
    end

    def run_pod_install
      puts "\nRunning " + "pod install".magenta + " on your new library."
      puts ""

      Dir.chdir(".") do
        system "pod install"
      end
    end

    def clean_unuseful_files
      [".git", ".gitignore", ".travis.yml", ".mailmap", "LICENSE", "README.md", "bin", "configure", "lib", "markdown", "setup", "assets", "docs"].each do |asset|
        `rm -rf #{asset}`
      end
    end

    def clean_template_files
      ["template"].each do |asset|
        `rm -rf #{asset}`
      end
    end

    def add_pods_to_podfile
      podfile = File.read podfile_path
      podfile_content = @pods_for_podfile.map do |pod|
        "pod '" + pod + "'"
      end.join("\n    ")
      podfile.gsub!("${INCLUDED_PODS}", podfile_content)
      File.open(podfile_path, "w") { |file| file.puts podfile }
    end

    #----------------------------------------#

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

    def podfile_path
      'Podfile'
    end

    def license_path
      'LICENSE'
    end

    #----------------------------------------#
  end
end
