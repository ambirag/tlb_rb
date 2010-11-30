require 'tlb/run_data'

module Tlb::TestUnit::TestObserver
  class TestUnitRunData
    include Tlb::RunData

    def suite_failed(failure)
      update_suite_failed(suite_name_for(failure.test_name))
    end

    def suite_name_for(test_name)
      test_name.scan(/\((.+)\)$/).flatten.first
    end
  end
  
  def register_observers
    run_data = TestUnitRunData.new
    
    add_listener(Test::Unit::TestResult::FAULT) do |fault|
      run_data.suite_failed(fault)
    end

    add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED) do |*elapsed_time|
      run_data.report_all_suite_data
    end

    add_listener(Test::Unit::TestSuite::STARTED) do |suite_name|
      run_data.suite_started(suite_name)
    end


    add_listener(Test::Unit::TestSuite::FINISHED) do |suite_name|
      run_data.update_suite_data(suite_name)
    end
  end
end
