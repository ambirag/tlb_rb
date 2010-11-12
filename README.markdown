# How does it work...?

tlb_rb uses [tlb](https://github.com/test-load-balancer/tlb "TLB") under the hood. It runs a sub-process(java process) which talks to the actual tlb-server(or equivallent) to balance and post run-feedback.
Balancer process is actually an HTTP server which needs to listen to a certain TCP port so that tlb-ruby implementation can talk to it. 
This is controlled by an environment variable named *'TLB_BALANCER_PORT'*, which can be set to any port number(integer between 1024 to 65535) that is guaranteed to remain un-bound while the build runs.

The usual TLB environment variable setup is required(so that the balancer knows things like what balancing algorithm to use, and what server to talk to etc). Detailed documentation of environment variable configuration is available at [https://github.com/test-load-balancer/tlb/wiki/Configuration-Variables](https://github.com/test-load-balancer/tlb/wiki/Configuration-Variables "Tlb config reference")

