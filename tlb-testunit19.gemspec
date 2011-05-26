$module_name="testunit"
$framework='test::unit'
$name="tlb-testunit19"
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  depends_on_core s
  s.add_runtime_dependency 'test-unit'
  s.required_ruby_version = '>= 1.9.1'
end
