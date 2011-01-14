## Using tlb_rb:

tlb_rb uses [tlb](https://github.com/test-load-balancer/tlb "TLB") under the hood. It runs a sub-process(java process) which talks to the actual tlb-server(or equivallent) to balance and post run-feedback.
Balancer process is actually an HTTP server which needs to listen to a certain TCP port so that tlb-ruby implementation can talk to it. 
This is controlled by an environment variable named *'TLB_BALANCER_PORT'*, which can be set to any port number(integer between 1024 to 65535) that is guaranteed to remain un-bound while the build runs.

In addition to this extra environment variable, the usual TLB environment variable setup is required(so the balancer knows things like what partitioning algorithm to use or what server to talk to). 
Detailed documentation of TLB environment variable configuration is available at [http://test-load-balancer.github.com](http://test-load-balancer.github.com "Tlb Documentation")

tlb_rb supports RSpec(1.x and 2.x) and Test::Unit, which are the two most widely used testing frameworks in Ruby. We plan to add support for other ruby-testing-frameworks soon.

## Setting it up for your project

Please refer the [sample_projects](http://github.com/test-load-balancer/sample_projects "Tlb setup examples") to see the details of how to set it up.

Usually, something equivallent of this in one of your Rake files should suffice:
__RSpec-1.x__:    
    require 'rubygems'
    gem 'tlb-rspec1'
    require 'tlb'
    require File.join('tlb/spec_task')

    Tlb::SpecTask.new(:balanced_specs) do |t|
      t.spec_files = FileList['spec/**/*_spec.rb']
      t.spec_opts << "--format progress"
    end

    load 'tasks/tlb.rake'
    desc "load balanced spec"
    task :bal => ['tlb:start', :balanced_specs]

__RSpec-2.x__:
    require 'rubygems'
    gem 'tlb-rspec2'
    require 'tlb'
    require 'tlb/rspec/spec_task'
    require 'rake'
    
    Tlb::RSpec::SpecTask.new(:run_balanced) do |t|
      t.pattern = 'spec/**/*_spec.rb'
    end
    
    load 'tasks/tlb.rake'
    desc "load balanced spec"
    task :bal => ['tlb:start', :run_balanced]

__Test::Unit__:
    require 'rubygems'
    gem 'tlb-testunit'
    require 'tlb'
    require 'tlb/test_unit/test_task'
    require 'rake'
    require 'rake/testtask'
    
    Tlb::TestUnit::TestTask.new(:test_balanced) do |t|
      t.libs << "test"
      t.test_files = FileList['test/**/*_test.rb']
      t.verbose = true
    end
    
    load 'tasks/tlb.rake'
    desc "load balanced tests"
    task :bal => ['tlb:start', :test_balanced]
  
Where __bal__ is the task you invoke at the top-level(invoked externally).

## RSpec source-control and release-version/environment compatibility
  The branch '__master__' supports __Test::Unit__ and __RSpec-2.x__ compatible. If you use __RSpec-1__(i.e. __1.3.x__ etc), please use branch named '__rspec-1__'. 
  If you come across any bugs with eiher Test::Unit, RSpec-2.x or RSpec-1.x support, please post it as a bug on the [Issue Tracker](http://code.google.com/p/tlb/issues/list "Issue Tracker").
  
