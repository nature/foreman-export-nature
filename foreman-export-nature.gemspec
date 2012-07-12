Gem::Specification.new do |gem|
  gem.name    = 'foreman-export-nature'
  gem.version = '0.0.2'
  gem.date    = Date.today.to_s

  gem.add_dependency 'foreman', '<= 0.45.0'

  gem.add_development_dependency 'rspec',   '~> 2.8.0'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'ZenTest', '~> 4.4.2'

  gem.summary = "Nature export scripts for foreman"
  gem.description = "Nature export scripts for foreman"

  gem.authors  = ['Chris Lowder']
  gem.email    = 'c.lowder@nature.com'
  gem.homepage = 'http://github.com/nature/foreman-export-nature'

  gem.has_rdoc = false
  gem.extra_rdoc_files = ['README.md']

  gem.files = Dir['{lib,data}/**/*', 'README.md']
end
