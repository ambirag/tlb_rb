require 'tlb'
require 'tlb/run_data'

module Tlb::TestUnit::TestObserver
  class TestUnitRunData
    include Tlb::RunData

    def initialize capture_for_suites
      @capture_for_suites = capture_for_suites
    end

    def notify_suite_started suite_name
      if @capture_for_suites.include?(suite_name)
        suite_started suite_name
      end
    end

    def notify_update_suite_data suite_name
      if @capture_for_suites.include?(suite_name)
        update_suite_data(suite_name)
      end
    end

    def suite_failed(failure)
      suite_name = suite_name_for(failure.test_name)
      if @capture_for_suites.include?(suite_name)
        update_suite_failed(suite_name)
      end
    end

    def suite_name_for(test_name)
      test_name.scan(/\((.+)\)$/).flatten.first
    end
  end

  def register_observers capture_for_suites
    run_data = TestUnitRunData.new(capture_for_suites)

    add_listener(Test::Unit::TestResult::FAULT) do |fault|
      run_data.suite_failed(fault)
    end

    add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED) do |*elapsed_time|
      run_data.report_all_suite_data
    end

    add_listener(Test::Unit::TestSuite::STARTED) do |suite_name|
      run_data.notify_suite_started(suite_name)
    end

    add_listener(Test::Unit::TestSuite::FINISHED) do |suite_name|
      run_data.notify_update_suite_data(suite_name)
    end
  end
end
