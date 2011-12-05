require 'cucumber/rake/task'
require 'tlb/util'
require 'tlb/cucumber/lib/configuration_inflection'

module Tlb
  module Cucumber
    module Rake
      class CucumberTask < ::Cucumber::Rake::Task

        attr_accessor :tlb_module_name

        def initialize(*args)
          super(args) do |this|
            yield this if block_given?
            this.cucumber_opts ||= []
            this.cucumber_opts = [this.cucumber_opts, "#{File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))}", 'features'].flatten
          end
        end

        class SynchronizedRunner
          RUN_LOCK = Mutex.new

          def initialize runner, tlb_module_name
            @tlb_module_name = tlb_module_name
            @runner = runner
          end

          def run
            RUN_LOCK.synchronize do
              old_val = ENV[Tlb::TLB_MODULE_NAME]
              begin
                ENV[Tlb::TLB_MODULE_NAME] = @tlb_module_name
                @runner.run
              ensure
                ENV[Tlb::TLB_MODULE_NAME] = old_val
              end
            end
          end
        end

        def runner *args
          synchronized_runner_for(super)
        end

        def synchronized_runner_for runner
          SynchronizedRunner.new(runner, tlb_module_name)
        end
      end
    end
  end
end
