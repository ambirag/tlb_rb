BASE_DIR = File.dirname(__FILE__)
LIB_TLB = File.join(BASE_DIR, "lib", "tlb")
TEST_DIR = File.join(BASE_DIR, "tests")
TAG_VERSION = `git describe --abbrev=0`.gsub(/^v/, '')
CODE_VERSION = `git describe --always`
AUTHORS = ["Janmejay Singh", "Pavan KS"]
EMAIL = "singh.janmejay@gmail.com;itspanzi@gmail.com"
HOME_PAGE = "http://github.com/test-load-balancer/tlb_rb"
SUMMARY = "#{$name}-#{CODE_VERSION}"
DESC = "TLB ruby implementation base, which provides support for load balancing tests written in #{$framework}. TLB_rb test suite is not bundled, please check http://github.com/test-load-balancer/tlb_rb for tests"
RUBYGEMS_VERSION = "1.3.7"

def files *exclude_dirs
  files = `git ls-files`.split("\n")
  files += Dir.glob(File.join(File.dirname(__FILE__), "*.jar")).map { |path| File.basename(path) }
  exclude_dirs.inject(files) { |files, dir| files - `git ls-files #{dir}`.split("\n") }
end
