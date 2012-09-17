require 'pathname'
require 'foreman/export'
require 'foreman/cli'

class Foreman::Export::NatureRunit < Foreman::Export::Base
  @template_root = Pathname.new(File.dirname(__FILE__)).join('../../../data/templates')

  class << self
    attr_reader :template_root
  end

  def export
    error("Must specify a location") unless location

    cwd = Pathname.new(engine.root)
    export_to = Pathname.new(location)

    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        full_name = "#{app}-#{name}-#{num}"
        port      = engine.port_for(process, num)
        env       = engine.env.merge("PORT" => port)

        service = Nature::Service.new(full_name, process.command, cwd, export_to, env)
        service.create!
        service.activate!
      end
    end
  end
end
