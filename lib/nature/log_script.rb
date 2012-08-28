require 'shellwords'

module Nature
  class LogScript
    @template = Foreman::Export::NatureRunit.template_root.join('log.erb')

    class << self
      attr_reader :template
    end

    attr_reader :path, :log_to

    def initialize(args={})
      @path = args.fetch(:path)
      @log_to = args.fetch(:log_to)
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
