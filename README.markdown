## Using tlb.rb:

tlb.rb uses [tlb](https://github.com/test-load-balancer/tlb "TLB") under the hood. It runs a sub-process which talks to the actual tlb-server(or equivallent) to balance and post run-feedback.
Balancer process is actually an HTTP server which listen to a certain TCP port so tlb-ruby library can talk to it. 
This is controlled by an environment variable named *'TLB_BALANCER_PORT'*, which can be set to any port number(integer between 1024 to 65535) that is guaranteed to remain un-bound while the build runs.

In addition to this extra environment variable, the usual TLB environment variable setup is required(so the balancer knows things like what partitioning algorithm to use or the type of server it has to talk to etc). 
Detailed documentation of TLB environment variable configuration is available at [http://test-load-balancer.github.com](http://test-load-balancer.github.com "Tlb Documentation")

tlb.rb supports RSpec(1.x and 2.x), Cucumber and Test::Unit, which are the most widely used testing frameworks in Ruby. 

We test tlb.rb on MRI and JRuby, however it should work with other flavours of Ruby too. 

As of now, tlb.rb is Ruby 1.8.7 compatible, we are working towards adding Ruby 1.9 support.

## Setting it up for your project

Please refer documentation on [http://test-load-balancer.github.com/](http://test-load-balancer.github.com/ "TLB Website") for detailed setup instructions. 

Documentation also explains TLB concepts and customization options in fair amount of detail. We highly recomend going through the TLB documentation.

## Want a feature? Found a bug? 

Post it at [Issue Tracker](http://code.google.com/p/tlb/issues/list "Issue Tracker").
  
