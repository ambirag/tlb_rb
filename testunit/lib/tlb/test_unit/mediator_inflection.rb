require 'rubygems'
require 'tlb'
require File.join('tlb', 'test_unit', 'test_splitter')
require File.join('tlb', 'test_unit', 'test_observer')
require File.join('test', 'unit', 'ui', 'testrunnermediator')

module Tlb::TestUnit::MediatorInflection
  def self.included base
    base.send(:alias_method, :run_suite_without_tlb, :run_suite)
    base.send(:remove_method, :run_suite)
    base.send(:include, InstanceMethods)

    base.send(:include, Tlb::TestUnit::TestSplitter)
    base.send(:include, Tlb::TestUnit::TestObserver)
  end

  module InstanceMethods
    def run_suite
      register_observers(prune_suite)
      run_suite_without_tlb
    end
  end

end

Test::Unit::UI::TestRunnerMediator.class_eval do
  include Tlb::TestUnit::MediatorInflection
end
