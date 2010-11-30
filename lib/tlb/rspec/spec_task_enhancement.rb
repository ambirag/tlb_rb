module Tlb::RSpec::SpecTaskEnhancement
  def self.included base
    base.class_eval do
      alias_method :rspec_files_to_run, :files_to_run

      def files_to_run
        balanced_and_reordered = Tlb.balance_and_order(rspec_files_to_run.to_a)
        FileList[*balanced_and_reordered]
      end
    end
  end
end
