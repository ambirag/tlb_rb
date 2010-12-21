Gem::Specification.new do |s|
  s.name        = "tlb"
  s.version     = `git describe --abbrev=0`.gsub(/^v/, '')
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Janmejay Singh", "Pavan KS"]
  s.email       = "singh.janmejay@gmail.com;itspanzi@gmail.com"
  s.homepage    = "http://github.com/test-load-balancer/tlb_rb"
  s.summary     = "tlb-" + `git describe --always`
  s.description = "TLB ruby implementation, which allows load balancing of rspec/test::unit tests"

  s.rubygems_version   = "1.3.7"

  s.files            = `git ls-files`.split("\n") + Dir.glob(File.join(File.dirname(__FILE__), "*.jar")).map { |path| File.basename(path) }
  s.test_files       = `git ls-files -- {tests}/*`.split("\n")
  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency 'open4', '>= 1.0.1'
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rspec', '>= 2.3.0'

  s.add_development_dependency 'mocha'
  s.add_development_dependency 'gemcutter'
end
