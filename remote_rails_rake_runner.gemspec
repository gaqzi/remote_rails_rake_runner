$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'remote_rails_rake_runner/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'remote_rails_rake_runner'
  s.version     = RemoteRailsRakeRunner::VERSION
  s.authors     = ['Björn Andersson']
  s.email       = ['ba@sanitarium.se']
  s.homepage    = 'https://github.com/gaqzi/remote_rails_rake_runner'
  s.summary     = 'A simple API endpoint to run your rake tasks in the Rails context.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails'
end
