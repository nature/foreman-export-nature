$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler'
Bundler.require(:test)

require 'fakefs/spec_helpers'
require 'foreman-export-nature'
require 'foreman/engine'

def write_procfile(location, content)
  dir = File.dirname(location)

  FileUtils.mkdir_p(dir)
  File.open(location, 'w') do |file|
    file << content
  end

  location
end
