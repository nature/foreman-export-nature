$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler'
Bundler.require(:test)

require 'foreman-export-nature'
require 'foreman/engine'
