module Pod

  class ConfigureNef
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "template/PROJECT.xcodeproj",
        :platform => :osx,
        :prefix => ''
      }).run

      `mv ./template/* ./`
    end
  end

end
