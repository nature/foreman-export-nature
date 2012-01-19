class Foreman::Export::NatureRunit::Service
  @run_template = Foreman::Export::NatureRunit.template_root.join('run.erb')
  @log_template = Foreman::Export::NatureRunit.template_root.join('log.erb')

  class << self
    attr_reader :run_template, :log_template
  end

  attr_reader :command, :target, :execution_target, :active_target, :environment,
    :environment_target, :logging_target

  def initialize(name, command, execution_target, export_target, environment)
    @target             = export_target.join(name).expand_path
    @active_target      = export_target.join('..', '..', 'service', name).expand_path
    @logging_target     = export_target.join('..', '..', 'var', 'log', name).expand_path
    @environment_target = @target.join('env').expand_path
    @environment        = environment
    @execution_target   = execution_target
    @command            = command
  end

  def create!
    export_run_script!
    export_log_script!
  end

  def export_log_script!
    log_script_path = target.join('log', 'run')

    create_if_missing(target.join('log'))
    create_if_missing(logging_target)

    write_file(log_script_path, log_script)
    FileUtils.chmod(0755, log_script_path.to_s)
  end

  def log_script
    erb_template = ERB.new(self.class.log_template.read)
    erb_template.result(binding)
  end

  def export_run_script!
    run_script_path = target.join('run')

    create_if_missing(target)
    write_file(run_script_path, run_script)
    FileUtils.chmod(0755, run_script_path.to_s)
  end

  def run_script
    erb_template = ERB.new(self.class.run_template.read)
    erb_template.result(binding)
  end

  def activate!
    FileUtils.ln_sf(target, active_target)
  end

  private
  def create_if_missing(pathname)
    unless File.directory?(pathname)
      FileUtils.mkdir_p(pathname)
    end
  end

  def write_file(pathname, contents)
    File.open(pathname, "w") do |file|
      file << contents
    end
  end
end