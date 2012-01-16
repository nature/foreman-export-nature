require 'foreman/export'

class Foreman::Export::NatureRunit < Base
  autoload :Service, 'foreman/export/nature_runit/service'
end