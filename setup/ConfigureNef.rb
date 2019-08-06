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

      Nef::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "template/osx/PROJECT.xcodeproj",
        :platform => :osx,
        :prefix => ''
      }).run

      Nef::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "template/ios/PROJECT.xcodeproj",
        :platform => :ios,
        :prefix => ''
      }).run

      `mv ./template/* ./`
      `mv template/.gitignore ./`
    end
  end

end
