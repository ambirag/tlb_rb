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
end

