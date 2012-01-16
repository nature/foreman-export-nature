class Foreman::Export::NatureRunit::Service
  attr_reader :directory, :active_target

  def initialize(name, target)
    @directory     = target.join(name).expand_path
    @active_target = target.join('..', '..', 'service', name).expand_path
  end
end