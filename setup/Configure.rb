module Pod

  class ConfigureIOS
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
        :xcodeproj_path => "templates/PROJECT.xcodeproj",
        :platform => :ios,
        :remove_demo_project => true,
        :prefix => nil
      }).run

      # There has to be a single file in the Classes dir
      # or a framework won't be created, which is now default
      `touch Pod/Classes/ReplaceMe.m`

      `mv ./templates/ios/* ./`
    end
  end

end
