$name="tlb-rspec2"
$framework='rspec-2.x'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)

  s.files            = files('tests', File.join('lib', 'tlb', 'test_unit'))

  s.add_runtime_dependency 'rspec', '>= 2.3.0'
end
