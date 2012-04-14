require 'tlb'
require File.join('tlb', 'run_data')

module Tlb
  module Cucumber
    module Lib
      class RunDataFormatter
        include Tlb::RunData

        def initialize(*args)
        end

        def before_feature(*args)
          suite_started(feature_file args)
        end

        def after_feature(*args)
          update_suite_failed(feature_file args) if @failed
          update_suite_data(feature_file args)
        end

        def after_step_result(*args)
          @failed = args[3] != :passed && args[3] != :pending
        end

        def after_features(*args)
          report_all_suite_data
        end

        private

        def feature_file args
          args[0].file
        end
      end
    end
  end
end
