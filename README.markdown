## Using tlb.rb:

__tlb.rb__ uses [tlb](https://github.com/test-load-balancer/tlb "TLB") under the hood. It runs a sub-process which talks to the actual tlb-server(or equivallent) to balance and post run-feedback.
Balancer process is actually an HTTP server which listen to a certain TCP port so tlb-ruby library can talk to it. 
This is controlled by an environment variable named *'TLB_BALANCER_PORT'*, which can be set to any port number(integer between 1024 to 65535) that is guaranteed to remain un-bound while the build runs.

In addition to this extra environment variable, the usual TLB environment variable setup is required(so the balancer knows things like what partitioning algorithm to use or the type of server it has to talk to etc). 
Detailed documentation of TLB environment variable configuration is available at [http://test-load-balancer.github.com](http://test-load-balancer.github.com "Tlb Documentation")

__tlb.rb__ supports RSpec(1.x and 2.x), Cucumber and Test::Unit, which are the most widely used testing frameworks in the Ruby world. 

__tlb.rb__ is fully compatible with both Ruby 1.9 and 1.8 across __MRI__ and __JRuby__. However, 1.9 support will be available only version 0.3.2 onwards.

We test __tlb.rb__ on MRI and JRuby, however it should work with other flavours of Ruby(like REE) as well.

## Getting tlb.rb:

__RSpec2__ support(both __1.9__ and __1.8__):
    $ gem install tlb-rspec2

__Cucumber__ support(both __1.9__ and __1.8__):
    $ gem install tlb-cucumber

__RSpec1__ support(both __1.9__ and __1.8__):
    $ gem install tlb-rspec1

__Test::Unit__ support on Ruby __1.9__:(available 0.3.2 onwards)
    $ gem install tlb-testunit19

__Test::Unit__ support on Ruby __1.8__:(available 0.3.2 onwards)
    $ gem install tlb-testunit18
    
If a version older than 0.3.2, please use 
    $ gem install tlb-testunit
for Test::Unit support.
    
## Setting it up for your project

Please refer documentation on [http://test-load-balancer.github.com/](http://test-load-balancer.github.com/ "TLB Website") for detailed setup instructions. 

Documentation also explains TLB concepts and customization options in fair amount of detail. We highly recomend going through the TLB documentation.

## Want a feature? Found a bug? 

Post it at [Issue Tracker](http://code.google.com/p/tlb/issues/list "Issue Tracker").
  
