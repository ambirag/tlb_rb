require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/lib/test_splitter'

describe Tlb::Cucumber::Lib::TestSplitter do
  include Tlb::Cucumber::Lib::TestSplitter

  it "should invoke balance and order with relative paths" do
    Tlb.expects(:balance_and_order).with(["./foo/bar/baaz", './first/second', './another_name'], nil).returns(["./first/second"])
    prune_features(['foo/bar/baaz', 'first/second', 'another_name']).should == ['./first/second']
  end

  it "should report module-name for balancer_and_order call" do
    old_val = nil
    begin
      old_val = ENV[Tlb::TLB_MODULE_NAME]
      ENV[Tlb::TLB_MODULE_NAME] = 'my-ruby-cucumber-module'
      Tlb.expects(:balance_and_order).with(["./foo/bar/baaz", './first/second', './another_name'], 'my-ruby-cucumber-module').returns(["./first/second"])
      prune_features(['foo/bar/baaz', 'first/second', 'another_name']).should == ['./first/second']
    ensure
      ENV[Tlb::TLB_MODULE_NAME] = old_val
    end
  end
end
