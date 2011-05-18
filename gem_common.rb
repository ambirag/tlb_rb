NAME = "tlb-#{$module_name}"
BASE_DIR = File.dirname(__FILE__)
LIB_DIR = "lib"
TAG_VERSION = `git describe --abbrev=0`.gsub(/^v/, '')
CODE_VERSION = `git describe --always`
AUTHORS = ["Janmejay Singh", "Pavan KS"]
EMAIL = "singh.janmejay@gmail.com;itspanzi@gmail.com"
HOME_PAGE = "http://github.com/test-load-balancer/tlb.rb"
SUMMARY = "#{NAME}-#{CODE_VERSION}"
$description ||= <<END
TLB-Ruby component that provides support for load balancing tests written using #{$framework}. This library consumes APIs provided by tlb-core.
END

$post_install_message ||= <<END
=========================================================================
Documentation: Detailed configuration documentation can be found at http://test-load-balancer.github.com. Documentation section in this website hosts documentation for every public release.

-------------------------------------------------------------------------
TLB Setup: You'll need a TLB-Server in your network that is reachable over the network from the machines you use to execute your project's test-suite. Please refer the TLB documentation for details.

-------------------------------------------------------------------------
Example(s): We maintain a directory of tlb-enabled dummy projects written in different languages using different testing and build frameworks to help new TLB users get started and provide users a working project to refer to while hooking up TLB on their project(s).
Each of these projects have a shell script(named run_balanced.sh) that is meant to demonstrate a typical tlb-enabled build(by starting a local tlb server, and executing two partitions that run dummy tests locally). This script also starts its own server(so you do not need to worry about the TLB server for trying it out).
We recommend playing with the configuration-variable values being set in the shell-script(s) to understand the effect different values have on load-balancing/reordering behavior.

Examples archive is released along-with TLB and is available for download at http://code.google.com/p/tlb/downloads/list.

To execute the example project, drop into the example project directory(examples/rspec2_example for instance) and invoke the './run_balanced.sh'.

-------------------------------------------------------------------------
Issue Tracker: http://code.google.com/p/tlb/issues/list

=========================================================================
END
RUBYFORGE_PROJECT = "tlb-rb"
RUBYGEMS_VERSION = "1.3.7"


def module_files
  files = `git ls-files #{$module_name}/#{LIB_DIR}`.split("\n")
end

def depends_on_core s
  s.add_runtime_dependency 'tlb-core', "#{TAG_VERSION}"
end


def configure_tlb s
  s.name        = NAME
  s.version     = TAG_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = AUTHORS
  s.email       = EMAIL
  s.homepage    = HOME_PAGE
  s.summary     = SUMMARY
  s.description = $description

  s.rubyforge_project = RUBYFORGE_PROJECT
  s.rubygems_version = RUBYGEMS_VERSION

  s.post_install_message = $post_install_message

  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]

  s.files = module_files

  s.require_path     = "#{$module_name}/#{LIB_DIR}"

  s.add_runtime_dependency 'open4', '>= 1.0.1'
  s.add_runtime_dependency 'rake'
end
