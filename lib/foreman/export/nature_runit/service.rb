class Foreman::Export::NatureRunit::Service
  @run_template = Foreman::Export::NatureRunit.template_root.join('run.erb')

  class << self
    attr_reader :run_template
  end

  attr_reader :command, :target, :active_target, :environment, :environment_target

  def initialize(name, command, target, environment)
    @target             = target.join(name).expand_path
    @active_target      = target.join('..', '..', 'service', name).expand_path
    @environment_target = @target.join('env').expand_path
    @environment        = environment
    @command            = command
  end

  def create!
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