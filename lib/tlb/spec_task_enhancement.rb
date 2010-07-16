module Tlb::SpecTaskEnhancement
  def self.included base
    base.class_eval do
      alias_method :rspec_spec_file_list, :spec_file_list

      def spec_file_list
        Tlb.start_unless_running
        balanced_and_reordered = Tlb.balance_and_order(rspec_spec_file_list.to_a)
        FileList[*balanced_and_reordered]
      end
    end
  end
end
