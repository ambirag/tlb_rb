$module_name = 'server'
$description = <<END
TLB Server that provides storage, correctness-check and versioning infrastructure for test data. This gem can often prove a convinient alternative to downloading tlb-server archive from http://code.google.com/p/tlb/downloads/list and using shell scripts to managing it.
END

$post_install_message = <<END
=========================================================================
Documentation: Detailed configuration documentation can be found at http://test-load-balancer.github.com. Documentation section in this website hosts documentation for every public release.

-------------------------------------------------------------------------
TLB Setup: You'll need to use 'tlb-server start' and 'tlb-server stop' command to start or stop TLB-Server. This server must be reachable over the network from the machines you use to execute your project's test-suite. Please refer the TLB documentation for details.

-------------------------------------------------------------------------
Note: TLB Server provides storage, correctness-check and versioning infrastructure for test data. This gem is just a convinient alternative to downloading tlb-server archive from http://code.google.com/p/tlb/downloads/list and using shell scripts to manage it.

=========================================================================
END


require File.join(File.dirname(__FILE__), 'gem_common')

Gem::Specification.new do |s|
  configure_tlb(s)
  s.files = Dir.glob(File.join(File.dirname(__FILE__), 'server', 'tlb-server*.jar')) + Dir.glob(File.join(File.dirname(__FILE__), 'server', 'lib', '*'))
  s.bindir = 'server/bin'
  s.executables << 'tlb-server'
end

