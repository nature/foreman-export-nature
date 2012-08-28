require 'shellwords'

module Nature
  class RunScript
    @template = Foreman::Export::NatureRunit.template_root.join('run.erb')

    class << self
      attr_reader :template
    end

    attr_reader :name, :command, :env, :cwd

    def initialize(args={})
      @name = args.fetch(:name)
      @command = args.fetch(:command)
      @env = args.fetch(:env)
      @cwd = args.fetch(:cwd)
    end

    def content
      ERB.new(self.class.template.read, nil, '<>').result(binding)
    end

    def export
      export_to  = File.expand_path(File.join('~/etc/sv/', name))
      run_script = File.join(export_to, 'run')

      FileUtils.mkdir_p(export_to)
      File.open(run_script, 'wb') { |f| f.write(content) }
      File.chmod(0755, run_script)
    end
  end
end
