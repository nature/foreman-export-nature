module Nature
  class Service
    class << self
      attr_reader :run_template, :log_template
    end

    attr_reader :command, :environment, :cwd, :target, :active_target, :run_script_path, :log_script_path,
      :log_dir

    def initialize(name, opts={})
      @command     = opts.fetch(:command)
      @environment = opts.fetch(:environment)
      @cwd         = opts.fetch(:cwd).to_s

      export_to      = opts.fetch(:export_to)

      @target        = export_to.join(name).to_s
      @active_target = export_to.join('..', '..', 'service').to_s

      @run_script_path = export_to.join(name, 'run').to_s
      @log_script_path = export_to.join(name, 'log/run').to_s
      @log_dir         = export_to.join('../../var/log', name).to_s
    end

    def create!
      FileUtils.mkdir_p(log_dir)

      Nature::RunScript.new(:path => run_script_path, :command => command, :env => environment, :cwd => cwd).export
      Nature::LogScript.new(:path => log_script_path, :log_to => log_dir).export
    end

    def activate!
      FileUtils.ln_sf(target, active_target)
    end
  end
end
