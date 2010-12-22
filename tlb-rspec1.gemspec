$name="tlb-rspec1"
$framework='rspec-1.x'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)

  s.files            = files('tests', File.join('lib', 'tlb', 'test_unit'))

  s.add_development_dependency 'rspec', '>= 1.3.0'
end
