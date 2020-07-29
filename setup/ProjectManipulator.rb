
module Nef

  class ProjectManipulator
    attr_reader :configurator, :xcodeproj_path, :platform, :prefix, :string_replacements

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
      @xcodeproj_path = options.fetch(:xcodeproj_path)
      @platform = options.fetch(:platform)
      @prefix = options.fetch(:prefix)
      @string_replacements = {
        "PROJECT_OWNER" => @configurator.user_name,
        "TODAYS_DATE" => @configurator.date,
        "TODAYS_YEAR" => @configurator.year,
        "PROJECT" => @configurator.project_name,
        "${POD_NAME}" => @configurator.project_name
      }
    end

    def run
      replace_internal_project_settings
      rename_files
      rename_project_folder
    end

    def project_folder
      File.dirname @xcodeproj_path
    end

    def rename_files
      # shared schemes have project specific names
      scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
      File.rename(scheme_path + "PROJECT.xcscheme", scheme_path +  @configurator.project_name + ".xcscheme")

      # rename xcproject
      File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.project_name + ".xcodeproj")

      # rename playground
      File.rename(project_folder + "/PROJECT.playground", project_folder + "/" +  @configurator.project_name + ".playground")

      # rename xcworkspace
      workspace_path = project_folder + "/PROJECT.xcworkspace"
      if Dir.exist?(workspace_path)
          File.rename(workspace_path, project_folder + "/" +  @configurator.project_name + ".xcworkspace")
      end
    end

    def rename_project_folder
      if Dir.exist? project_folder + "/PROJECT"
        File.rename(project_folder + "/PROJECT", project_folder + "/" + @configurator.project_name)
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
