$name="tlb-rspec1"
$framework='rspec-1.x'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  s.name        = $name
  s.version     = TAG_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = AUTHORS
  s.email       = EMAIL
  s.homepage    = HOME_PAGE
  s.summary     = SUMMARY
  s.description = DESC

  s.rubygems_version = RUBYGEMS_VERSION

  s.files            = files('spec')
  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency 'open4', '>= 1.0.1'
  s.add_runtime_dependency 'rake'

  s.add_development_dependency 'rspec', '>= 1.3.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'gemcutter'
end
