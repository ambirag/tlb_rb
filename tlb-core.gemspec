$module_name = 'core'
$description = <<END
TLB-Ruby base library that provides common test-load-balancing infrastructure for Ruby testing tools. Core in itself is framework agnostic. It exposes APIs that allow any framework specific libraries to load-balance.
END

$post_install_message = <<END
=========================================================================
Documentation: Detailed configuration documentation can be found at http://test-load-balancer.github.com. Documentation section in this website hosts documentation for every public release.

-------------------------------------------------------------------------
TLB Setup: You'll need a TLB-Server in your network that is reachable over the network from the machines you use to execute your project's test-suite. Please refer the TLB documentation for details.

-------------------------------------------------------------------------
Note: Core is just the base library that implements common infrastructure for test-load-balancing in Ruby and is completely testing-framework agnostic. It exposes APIs that allow other ruby libraries to load-balance tests. You'll need to install one of the testing-framework specific libraries to make use of it.

=========================================================================
END


require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  s.add_runtime_dependency 'open4', '>= 1.0.1'
  s.files = module_files + Dir.glob(File.join(File.dirname(__FILE__), 'core', 'tlb-alien*.jar'))
end

