require 'pathname'
require 'foreman/export'
require 'nature'

class Foreman::Export::NatureRunit < Foreman::Export::Base
  def export
    error("Must specify a location") unless location

    cwd = Pathname.new(engine.root)
    export_to = Pathname.new(location)

    engine.each_process do |name, process|
      1.upto(engine.formation[name]) do |num|
        path = export_to.join("#{app}-#{name}-#{num}")
        port = engine.port_for(process, num)
        env  = engine.env.merge("PORT" => port)

        service = Nature::Service.new(path, :command => process.command,
                                            :cwd => cwd,
                                            :environment => env)
        service.create!
        service.activate!
      end
    end
  end
end
