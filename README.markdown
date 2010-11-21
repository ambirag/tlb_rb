## Using tlb_rb:

tlb_rb uses [tlb](https://github.com/test-load-balancer/tlb "TLB") under the hood. It runs a sub-process(java process) which talks to the actual tlb-server(or equivallent) to balance and post run-feedback.
Balancer process is actually an HTTP server which needs to listen to a certain TCP port so that tlb-ruby implementation can talk to it. 
This is controlled by an environment variable named *'TLB_BALANCER_PORT'*, which can be set to any port number(integer between 1024 to 65535) that is guaranteed to remain un-bound while the build runs.

In addition to this extra environment variable, the usual TLB environment variable setup is required(so the balancer knows things like what partitioning algorithm to use or what server to talk to). 
Detailed documentation of TLB environment variable configuration is available at [https://github.com/test-load-balancer/tlb/wiki/Configuration-Variables](https://github.com/test-load-balancer/tlb/wiki/Configuration-Variables "Tlb config reference")

As of now, rspec is the only test framework that tlb_rb supports. We plan to add support for other ruby-testing-frameworks soon.

## Setting it up for your project

Please refer the [sample_projects](http://github.com/test-load-balancer/sample_projects "Tlb setup examples") to see the details of how to set it up.

Usually, something equivallent of this in one of your Rake files should suffice:

    PATH_TO_TLB = File.join(RAILS_ROOT, 'vendor', 'plugins', 'tlb_rb', 'lib', 'tlb')
    require PATH_TO_TLB
    require File.join(PATH_TO_TLB, 'spec_task')
  
    Tlb::SpecTask.new(:balanced_specs) do |t|
      t.spec_files = FileList['spec/**/*_spec.rb']
      t.spec_opts << "--require #{PATH_TO_TLB},#{File.join(PATH_TO_TLB, 'spec_formatter')} --format 'Tlb::SpecFormatter:/dev/null' --format nested"
    end
  
    desc "load balanced spec"
    task :run_balanced => ['tlb:start', :balanced_specs]
  
Where run_balanced is the task you invoke at the top-level(invoked externally).

## RSpec version compatibility
  The branch '__master__' is __RSpec-2.x__ compatible. If you use __RSpec-1__(i.e. __1.3.x__ etc, please use branch named '__rspec-1__'. If you come across any bugs with eiher RSpec-2 or 1 support, please post it as an bug on the issue tracker on github project page.
