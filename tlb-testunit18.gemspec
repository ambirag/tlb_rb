$module_name="testunit"
$framework='test::unit'
$name="tlb-testunit18"
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  depends_on_core s
  s.required_ruby_version = '< 1.9'
end
