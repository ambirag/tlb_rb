require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tlb'))
require 'cucumber/cli/configuration'
require 'tlb/cucumber/lib/test_splitter'
require 'tlb/cucumber/lib/run_data_formatter'

module Tlb
  module Cucumber
    module Lib
      module ConfigurationInflection
        include Tlb::Cucumber::Lib::TestSplitter

        def self.included base
          unless base.included_modules.include?(InstanceMethods)
            base.send(:alias_method, :all_feature_files, :feature_files)
            base.send(:remove_method, :feature_files)
            base.send(:alias_method, :all_formatters, :formatters)
            base.send(:remove_method, :formatters)
            base.send(:include, InstanceMethods)
          end
        end

        module InstanceMethods
          def feature_files
            prune_features(all_feature_files)
          end

          def formatters(step_mother)
            formatters = all_formatters(step_mother)
            formatters << Tlb::Cucumber::Lib::RunDataFormatter.new
          end
        end
      end
    end
  end
end

Cucumber::Cli::Configuration.class_eval do
  include Tlb::Cucumber::Lib::ConfigurationInflection
end
