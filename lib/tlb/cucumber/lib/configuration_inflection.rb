require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tlb'))
require 'cucumber/cli/configuration'
require 'tlb/cucumber/lib/test_splitter'

module Tlb
  module Cucumber
    module Lib
      module ConfigurationInflection
        include Tlb::Cucumber::Lib::TestSplitter

        def self.included base
          base.send(:alias_method, :all_feature_files, :feature_files)
          base.send(:remove_method, :feature_files)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def feature_files
            prune_features(all_feature_files)
          end
        end
      end
    end
  end
end

Cucumber::Cli::Configuration.class_eval do
  include Tlb::Cucumber::Lib::ConfigurationInflection
end
