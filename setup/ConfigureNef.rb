module Nef

  class ConfigureNef
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform
      performProject("cocoapods")
      performProject("carthage")
      performProject("spm")

      `mv ./template/* ./`
      `mv template/.gitignore ./`
    end

    def performProject(dependency_manager)
        Nef::ProjectManipulator.new({
          :configurator => @configurator,
          :xcodeproj_path => "template/osx/"+dependency_manager+"/PROJECT.xcodeproj",
          :platform => :osx,
          :prefix => ''
        }).run

        # Nef::ProjectManipulator.new({
        #   :configurator => @configurator,
        #   :xcodeproj_path => "template/ios/"+dependency_manager+"/PROJECT.xcodeproj",
        #   :platform => :ios,
        #   :prefix => ''
        # }).run
    end
  end

end
