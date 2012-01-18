require 'foreman/export'
require 'foreman/cli'

class Foreman::Export::NatureRunit < Foreman::Export::Base
  @template_root = Pathname.new(File.dirname(__FILE__)).join('..', '..', '..', 'data', 'templates').expand_path

  class << self
    attr_reader :template_root
  end

  autoload :Service, 'foreman/export/nature_runit/service'

  def export
    error("Must specify a location") unless location

    @location = Pathname.new(@location)

    engine.procfile.entries.each do |process|
      1.upto(self.concurrency[process.name]) do |num|
        service_name          = "#{app}-#{process.name}-#{num}"
        port                  = engine.port_for(process, num, self.port)
        environment_variables = {'PORT' => port}.merge(engine.environment)

        service = Service.new(service_name, process.command, location, environment_variables)

        service.create!
        service.activate!
      end
    end
  end
end