$name="tlb-cucumber"
$framework='cucumber'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  s.files = files('tests', File.join('lib', 'tlb', 'rspec'), File.join('lib', 'tlb', 'test_unit'))
  s.add_runtime_dependency 'cucumber', '>= 0.10.2'
end
