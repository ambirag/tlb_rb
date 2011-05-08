require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tlb'))

module Tlb
  module Cucumber
    module Lib
      module TestSplitter

        def prune_features(feature_file_paths)
          Tlb.balance_and_order(Tlb.relative_file_paths(feature_file_paths))
        end
      end
    end
  end
end
