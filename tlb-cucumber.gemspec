$module_name = "cucumber"
$framework = 'cucumber'
require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  depends_on_core s
  s.add_runtime_dependency 'cucumber', '>= 0.10.2'
end
