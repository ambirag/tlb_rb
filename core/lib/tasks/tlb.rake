require 'rubygems'
require 'tlb'

namespace :tlb do
  task :start do
    Tlb.start_server
    at_exit do
      $stderr.write "terminating tlb server\n"
      Tlb.stop_server
    end
  end

  task :ensure_all_partitions_executed do
    tlb_module_name = ENV[Tlb::TLB_MODULE_NAME]
    Tlb.assert_all_partitions_executed(tlb_module_name)
  end
end

