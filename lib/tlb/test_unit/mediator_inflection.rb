require 'test_splitter'
require 'test_observer'
require 'test/unit/ui/testrunnermediator'

module Tlb::MediatorInflection
  def self.included base
    base.send(:alias_method, :run_suite_without_tlb, :run_suite)
    base.send(:remove_method, :run_suite)
    base.send(:include, InstanceMethods)

    base.send(:include, Tlb::TestSplitter)
    base.send(:include, Tlb::TestObserver)
  end

  module InstanceMethods
    def run_suite
      register_observers
      prune_suite
      run_suite_without_tlb
    end
  end

end

Test::Unit::UI::TestRunnerMediator.class_eval do
  include Tlb::MediatorInflection
end

