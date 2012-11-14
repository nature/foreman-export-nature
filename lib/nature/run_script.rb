require 'shellwords'

module Nature
  class RunScript
    @template = Nature.template_root.join('run.erb')

    class << self
      attr_reader :template
    end

    attr_reader :path, :command, :env, :cwd

    def initialize(args={})
      @path = args.fetch(:path)
      @command = args.fetch(:command)
      @env = args.fetch(:env)
      @cwd = args.fetch(:cwd)
    end

    def content
      ERB.new(self.class.template.read, nil, '<>').result(binding)
    end

    def export
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb') { |f| f.write(content) }
      File.chmod(0755, path)
    end
  end
end
