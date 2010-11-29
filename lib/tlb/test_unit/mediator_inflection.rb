require 'test/unit/ui/testrunnermediator'

module Tlb::MediatorInflection
  def self.included base
    base.send(:alias_method, :run_suite_internal, :run_suite)
    base.send(:remove_method, :run_suite)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def run_suite
      name_suite_map = @suite.tests.inject({}) { |map, test| map[test.name] = test; map }
      names_to_run = Tlb.balance_and_order(@suite.tests.map { |test| test.name })
      tests_to_run = names_to_run.inject([]) { |tests, name| tests << name_suite_map[name]; tests }
      @suite.instance_variable_set('@tests', tests_to_run)
      run_suite_internal
    end
  end
end

Test::Unit::UI::TestRunnerMediator.class_eval do
  include Tlb::MediatorInflection
end
