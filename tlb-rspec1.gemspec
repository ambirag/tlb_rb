$module_name="rspec1"
$framework='rspec-1.x'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  depends_on_core s
  s.add_runtime_dependency 'rspec', '>= 1.3.0', '< 2.0.0'
end
