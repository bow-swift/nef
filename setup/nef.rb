#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__)

require 'TemplateConfigurator'
require 'ConfigureNef'
require 'ProjectManipulator'

#: - MAIN <launcher>
if ARGV.length != 1
    puts "nef.rb <project name>"
    exit 1
end

Nef::TemplateConfigurator.new(ARGV[0]).run
