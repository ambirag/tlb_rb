require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'tlb/test_unit/test_splitter'
require 'test/unit/testsuite'

describe Tlb::TestUnit::TestSplitter do
  def suite name, *tests
    suite = Test::Unit::TestSuite.new(name)
    tests.each do |test|
      suite.tests << test
    end
    suite
  end

  before do
    @main_suite = suite("main_test",
                        suite("FooBarBazTest", "test_foo", "test_bar"),
                        suite("QuuxBangBoomTest", "test_baz", "test_quux"),
                        suite("HellYeahTest", "test_hell", "test_ya", "test_yeah"),
                        suite("HelloWorldTest", "test_hello_world"))

    @mediator = Class.new do
      attr_reader :suite

      def initialize suite
        @suite = suite
      end

      include Tlb::TestUnit::TestSplitter
    end.new(@main_suite)
    Tlb::ArgProcessor.reset!
  end

  after do
    Tlb::ArgProcessor.reset!
  end

  it "should call actual runner method with pruned suite after balancing and reordering" do
    Tlb.expects(:balance_and_order).with(["FooBarBazTest", "QuuxBangBoomTest", "HellYeahTest", "HelloWorldTest"], nil).returns(["QuuxBangBoomTest", "HellYeahTest"])
    @mediator.prune_suite
    @mediator.suite.name.should == "main_test"
    @mediator.suite.tests.map { |test| test.name }.should == ["QuuxBangBoomTest", "HellYeahTest"]
  end

  it "should call balancer for splitting/reordering with module name, when given" do
    ARGV << "-Arg:#{Tlb::TLB_MODULE_NAME}=foo-module"
    Tlb::ArgProcessor.parse!
    Tlb.expects(:balance_and_order).with(["FooBarBazTest", "QuuxBangBoomTest", "HellYeahTest", "HelloWorldTest"], 'foo-module').returns(["HellYeahTest", "QuuxBangBoomTest"])
    @mediator.prune_suite
    @mediator.suite.name.should == "main_test"
    @mediator.suite.tests.map { |test| test.name }.should == ["HellYeahTest", "QuuxBangBoomTest"]
  end
end
