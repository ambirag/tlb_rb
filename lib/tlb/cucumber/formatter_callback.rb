require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tlb'))
require 'tlb/run_data'

module Tlb
  module Cucumber
    class FormatterCallback
      include Tlb::RunData

      def initialize(*args)
      end

      def before_feature(*args)
        puts args[0].file
      end

      def after_feature(*args)
      end

      def after_step_result(*args)
      end
    end
  end
end
