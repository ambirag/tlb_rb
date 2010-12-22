BASE_DIR = File.dirname(__FILE__)
LIB_TLB = File.join(BASE_DIR, "lib", "tlb")
TEST_DIR = File.join(BASE_DIR, "tests")
TAG_VERSION = `git describe --abbrev=0`.gsub(/^v/, '').gsub(/-rspec-1$/, '')
CODE_VERSION = `git describe --always`
AUTHORS = ["Janmejay Singh", "Pavan KS"]
EMAIL = "singh.janmejay@gmail.com;itspanzi@gmail.com"
HOME_PAGE = "http://github.com/test-load-balancer/tlb_rb"
SUMMARY = "#{$name}-#{CODE_VERSION}"
DESC = <<END
TLB ruby implementation base, which provides support for load balancing tests written in #{$framework}.
TLB_rb test suite is not bundled, please check http://github.com/test-load-balancer/tlb_rb for tests.
Detailed configuration documentation can be found at https://github.com/test-load-balancer/tlb/wiki.
END
POST_INSTALL_MESSAGE = <<END
-------------------------------------------------------------------------
Documentation: Detailed configuration documentation can be found at https://github.com/test-load-balancer/tlb/wiki.
-----------------------------
Example: https://github.com/test-load-balancer/sample_projects has examples projects and shell script to demonstrate a typical build(by starting a local tlb server, and executing two partitions locally). While partitions in these examples execute one after another, in an actual CI/pre-checkin build, they will actually run parallely on different machines.
Its a good idea to play with the environment variables values being used in these shell-scripts to understand how they affect TLB's behaviour. You may want to check https://github.com/test-load-balancer/tlb/wiki/Configuration-Variables, which documents each variable and its effect.
-----------------------------
Issue tracker: Please report bugs/enhancements/feature-requests at http://code.google.com/p/tlb/issues/list. Github, Rubyforge or any other issue trackers are not monitored or updated.
-------------------------------------------------------------------------
END
RUBYFORGE_PROJECT = "tlb-rb"
RUBYGEMS_VERSION = "1.3.7"

def files *exclude_dirs
  files = `git ls-files`.split("\n")
  files += Dir.glob(File.join(File.dirname(__FILE__), "*.jar")).map { |path| File.basename(path) }
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
end
