BASE_DIR = File.dirname(__FILE__)
LIB_TLB = File.join(BASE_DIR, "lib", "tlb")
TEST_DIR = File.join(BASE_DIR, "tests")
TAG_VERSION = `git describe --abbrev=0`.gsub(/^v/, '').gsub(/-rspec-1$/, '')
CODE_VERSION = `git describe --always`
AUTHORS = ["Janmejay Singh", "Pavan KS"]
EMAIL = "singh.janmejay@gmail.com;itspanzi@gmail.com"
HOME_PAGE = "http://github.com/test-load-balancer/tlb.rb"
SUMMARY = "#{$name}-#{CODE_VERSION}"
DESC = <<END
TLB ruby implementation base, which provides support for load balancing tests written in #{$framework}.
TLB.rb test suite is not bundled, please check http://github.com/test-load-balancer/tlb.rb for tests.
Detailed documentation is available at http://test-load-balancer.github.com.
END
POST_INSTALL_MESSAGE = <<END
-------------------------------------------------------------------------
TLB Documentation: Detailed configuration documentation can be found at http://test-load-balancer.github.com. Documentation section in this website hosts documentation for every public release.

-------------------------------------------------------------------------
TLB Example(s): We maintain a directory of tlb-enabled dummy projects written in different languages using different testing and build frameworks to help new TLB users get started and provide people a working project to refer to while hooking up TLB on their project(s). Each of these projects have a shell script(named run_balanced.sh) that is meant to demonstrate a typical tlb-enabled build(by starting a local tlb server, and executing two partitions that run dummy tests locally).
For demonstration purpose, aforementioned shell script executes partitions in the example-project one after another(serially). However, partitions will be executed parallely on different machines in a real-world setup(hence cutting the build time).
We recomend playing with the configuration-variable values being set in the shell-script(s) to understand the effect different values have on load-balancing/reordering behaviour. You may want to check http://test-load-balancer.github.com, which links to 'detailed documentation' that covers each configuration variable and explains its purpose, effect and implecation.

Examples archive is released alongwith TLB, and is available for download at http://code.google.com/p/tlb/downloads/list.

To execute the example project, drop into the example project directory(examples/rspec2_example for instance) and invoke the './run_balanced.sh'.

-------------------------------------------------------------------------
TLB Issue Tracker: Please report/port bugs/enhancements/feature-requests on http://code.google.com/p/tlb/issues/list. Github, Rubyforge or any other issue trackers are not monitored or updated.

-------------------------------------------------------------------------
END
RUBYFORGE_PROJECT = "tlb-rb"
RUBYGEMS_VERSION = "1.3.7"

def files *exclude_dirs
  files = `git ls-files`.split("\n")
  files += Dir.glob(File.join(File.dirname(__FILE__), "*.jar")).map { |path| File.basename(path) }
  files += Dir.glob(File.join(File.dirname(__FILE__), "doc", "**", "*"))
  exclude_dirs.inject(files) { |files, dir| files - `git ls-files #{dir}`.split("\n") }
end


def configure_tlb s
  s.name        = $name
  s.version     = TAG_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = AUTHORS
  s.email       = EMAIL
  s.homepage    = HOME_PAGE
  s.summary     = SUMMARY
  s.description = DESC

  s.rubyforge_project = RUBYFORGE_PROJECT
  s.rubygems_version = RUBYGEMS_VERSION

  s.post_install_message = POST_INSTALL_MESSAGE

  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency 'open4', '>= 1.0.1'
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rspec', '>= 1.3.0', '< 2.0.0'
end
