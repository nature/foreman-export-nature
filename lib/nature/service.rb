module Nature
  class Service
    class << self
      attr_reader :run_template, :log_template
    end

    attr_reader :command, :environment, :cwd, :path, :active_path, :run_script_path,
      :log_script_path, :log_dir

    def initialize(path, opts={})
      @command     = opts.fetch(:command)
      @environment = opts.fetch(:environment)
      @cwd         = opts.fetch(:cwd).to_s


      @path        = path.to_s
      @active_path = path.join('../../../service').to_s

      @run_script_path = path.join('run').to_s
      @log_script_path = path.join('log/run').to_s
      @log_dir         = path.join('../../../var/log', path.basename).to_s
    end

    def create!
      FileUtils.mkdir_p(log_dir)

      Nature::RunScript.new(:path => run_script_path, :command => command, :env => environment, :cwd => cwd).export
      Nature::LogScript.new(:path => log_script_path, :log_to => log_dir).export
    end

    def activate!
      FileUtils.mkdir_p(active_path)
      FileUtils.ln_sf(path, active_path)
    end
  end
end
