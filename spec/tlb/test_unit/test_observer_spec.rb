require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'test/unit/ui/testrunnermediator'
require 'test_observer'

describe Tlb::TestObserver do
  before do
    @mediator = Class.new(Test::Unit::UI::TestRunnerMediator) do
      include Tlb::TestObserver
    end.new(nil)
  end

  it "should report suite time" do
    @mediator.register_observers

    #suite one
    Time.stubs(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 10))
    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteOne')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_foo(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_foo(SuiteOne)')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_bar(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestResult::FAULT, Test::Unit::Failure.new('test_bar(SuiteOne)', ["./test/suite_one_test.rb:12:in `test_bar'", "./test/suite_one_test.rb:40:in `run_suite'"], "<10> expected but was\n<20>."))
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_bar(SuiteOne)')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_baz(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestResult::FAULT, Test::Unit::Failure.new('test_baz(SuiteOne)', ["./test/suite_one_test.rb:72:in `test_baz'", "./test/suite_one_test.rb:80:in `run_suite'"], "<20> expected but was\n<10>."))
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_baz(SuiteOne)')

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 29))
    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteOne')

    #suite two
    Time.stubs(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 00))
    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteTwo')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_one(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_one(SuiteTwo)')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_two(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_two(SuiteTwo)')

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 25))
    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteTwo')

    #suite three
    Time.stubs(:now).returns(Time.local( 2010, "jul", 16, 12, 7, 15))
    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteThree')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_alpha(SuiteThree)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_alpha(SuiteThree)')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_beta(SuiteThree)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_beta(SuiteThree)')

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 55))

    Tlb.stubs(:suite_result)
    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteThree')

    Tlb.expects(:suite_time).with("SuiteOne", 19000)
    Tlb.expects(:suite_time).with("SuiteTwo", 25000)
    Tlb.expects(:suite_time).with("SuiteThree", 100000)

    @mediator.notify_listeners(Test::Unit::UI::TestRunnerMediator::FINISHED, 10.3)#using some random number, no significance
  end

  it "should report suite result" do
    @mediator.register_observers

    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteOne')
    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_foo(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_foo(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_bar(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestResult::FAULT, Test::Unit::Failure.new('test_bar(SuiteOne)', ["./test/suite_one_test.rb:12:in `test_bar'", "./test/suite_one_test.rb:40:in `run_suite'"], "<10> expected but was\n<20>."))
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_bar(SuiteOne)')
    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteOne')


    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteTwo')
    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_one(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_one(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_two(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_two(SuiteTwo)')
    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteTwo')


    @mediator.notify_listeners(Test::Unit::TestSuite::STARTED, 'SuiteThree')
    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_alpha(SuiteThree)')
    @mediator.notify_listeners(Test::Unit::TestResult::FAULT, Test::Unit::Failure.new('test_alpha(SuiteThree)', ["./test/suite_threetest.rb:72:in `test_baz'", "./test/suite_one_test.rb:80:in `run_suite'"], "<true> expected but was\n<false>."))
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_alpha(SuiteThree)')

    @mediator.notify_listeners(Test::Unit::TestCase::STARTED, 'test_beta(SuiteThree)')
    @mediator.notify_listeners(Test::Unit::TestResult::FAULT, Test::Unit::Failure.new('test_beta(SuiteThree)', ["./test/suite_three_test.rb:72:in `test_baz'", "./test/suite_one_test.rb:80:in `run_suite'"], "<false> expected but was\n<true>."))
    @mediator.notify_listeners(Test::Unit::TestCase::FINISHED, 'test_beta(SuiteThree)')

    @mediator.notify_listeners(Test::Unit::TestSuite::FINISHED, 'SuiteThree')

    Tlb.stubs(:suite_time)

    Tlb.expects(:suite_result).with('SuiteOne', true)
    Tlb.expects(:suite_result).with('SuiteTwo', false)
    Tlb.expects(:suite_result).with('SuiteThree', true)

    @mediator.notify_listeners(Test::Unit::UI::TestRunnerMediator::FINISHED, 10.3)#using some random number, no significance
  end
end
