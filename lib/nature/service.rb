module Nature
  class Service
    class << self
      attr_reader :run_template, :log_template
    end

    attr_reader :command, :environment, :cwd, :target, :active_target, :run_script_path, :log_script_path,
      :log_dir

    def initialize(name, command, cwd, export_target, environment)
      @command     = command
      @environment = environment
      @cwd         = cwd.to_s

      @target        = export_target.join(name).to_s
      @active_target = export_target.join('..', '..', 'service').to_s

      @run_script_path = export_target.join(name, 'run').to_s
      @log_script_path = export_target.join(name, 'log/run').to_s
      @log_dir         = export_target.join('../../var/log', name).to_s
    end

    def create!
      Nature::RunScript.new(:path => run_script_path, :command => command, :env => environment, :cwd => cwd).export
      Nature::LogScript.new(:path => log_script_path, :log_to => log_dir).export
    end

    def activate!
      FileUtils.ln_sf(target, active_target)
    end
  end
end
