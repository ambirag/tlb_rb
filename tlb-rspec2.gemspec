$module_name = 'rspec2'
$framework='rspec-2.x'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  depends_on_core s
  s.add_runtime_dependency 'rspec', '>= 2.3.0'
end

