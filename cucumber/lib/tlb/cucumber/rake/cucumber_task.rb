require File.join('cucumber', 'rake', 'task')
require File.join('tlb', 'util')
require File.join('tlb' , 'cucumber' , 'lib' , 'configuration_inflection')

module Tlb
  module Cucumber
    module Rake
      class CucumberTask < ::Cucumber::Rake::Task

        DEFAULT_FEATURES_DIR_NAME = 'features'

        CUCUMBER_OPTS_MANAGEMENT_LOCK = Mutex.new

        attr_accessor :tlb_module_name
        attr_accessor :features_dir

        def initialize(*args)
          super(args) do |this|
            yield this if block_given?
            this.cucumber_opts ||= []
            if overridden_opts = ENV['CUCUMBER_OPTS']
              other_options = overridden_opts.split(/\s+/)
            else
              other_options = (this.cucumber_opts || [])
              f_dir = features_dir || DEFAULT_FEATURES_DIR_NAME
              other_options << "-r" << f_dir << f_dir
            end
            this.cucumber_opts = ["-r", "#{Tlb::Cucumber::Lib::ConfigurationInflection::FILE}", other_options].flatten
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
          CUCUMBER_OPTS_MANAGEMENT_LOCK.synchronize do
            old_cucumber_opts = ENV['CUCUMBER_OPTS']
            begin
              ENV.delete('CUCUMBER_OPTS')
              synchronized_runner_for(super)
            ensure
              ENV['CUCUMBER_OPTS'] = old_cucumber_opts
            end
          end
        end

        def synchronized_runner_for runner
          SynchronizedRunner.new(runner, tlb_module_name)
        end
      end
    end
  end
end
