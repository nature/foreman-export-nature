module Nature
  @template_root = Pathname.new(File.dirname(__FILE__)).join('../data/templates')
  class << self
    attr_reader :template_root
  end
end

require 'nature/service'
require 'nature/run_script'
require 'nature/log_script'
