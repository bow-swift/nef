require 'xcodeproj'

module Pod

  class ProjectManipulator
    attr_reader :configurator, :xcodeproj_path, :platform, :string_replacements, :prefix

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @xcodeproj_path = options.fetch(:xcodeproj_path)
      @configurator = options.fetch(:configurator)
      @platform = options.fetch(:platform)
      @prefix = options.fetch(:prefix)
    end

    def run
      @string_replacements = {
        "PROJECT_OWNER" => @configurator.user_name,
        "TODAYS_DATE" => @configurator.date,
        "TODAYS_YEAR" => @configurator.year,
        "PROJECT" => @configurator.pod_name
      }
      replace_internal_project_settings

      @project = Xcodeproj::Project.open(@xcodeproj_path)
      @project.save

      rename_files
      rename_project_folder
    end

    def project_folder
      File.dirname @xcodeproj_path
    end

    def rename_files
      # shared schemes have project specific names
      scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
      File.rename(scheme_path + "PROJECT-mac.xcscheme", scheme_path +  @configurator.pod_name + "-mac.xcscheme")
      File.rename(scheme_path + "PROJECT-ios.xcscheme", scheme_path +  @configurator.pod_name + "-ios.xcscheme")

      # rename xcproject
      File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.pod_name + ".xcodeproj")

      # rename playground
      File.rename(project_folder + "/PROJECT.playground", project_folder + "/" +  @configurator.pod_name + ".playground")
    end

    def rename_project_folder
      if Dir.exist? project_folder + "/PROJECT-mac"
        File.rename(project_folder + "/PROJECT-mac", project_folder + "/" + @configurator.pod_name + "-mac")
      end

      if Dir.exist? project_folder + "/PROJECT-ios"
        File.rename(project_folder + "/PROJECT-ios", project_folder + "/" + @configurator.pod_name + "-ios")
      end
    end

    def replace_internal_project_settings
      Dir.glob(project_folder + "/**/**/**/**").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        for find, replace in @string_replacements
            text = text.gsub(find, replace)
        end

        File.open(name, "w") { |file| file.puts text }
      end
    end

  end

end
