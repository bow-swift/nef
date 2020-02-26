#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__)

require 'TemplateConfigurator'
require 'ConfigureNef'
require 'ProjectManipulator'

#: - MAIN <launcher>
if ARGV.length != 2
    puts "nef.rb <project_path> <project_name>"
    exit 1
end

Dir.chdir ARGV[0]
Nef::TemplateConfigurator.new(ARGV[1]).run
