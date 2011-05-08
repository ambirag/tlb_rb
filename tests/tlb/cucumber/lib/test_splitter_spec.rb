require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/lib/test_splitter'

describe Tlb::Cucumber::Lib::TestSplitter do
  include Tlb::Cucumber::Lib::TestSplitter

  it "should invoke balance and order with relative paths" do
    Tlb.expects(:balance_and_order).with(["./foo/bar/baaz", './first/second', './another_name']).returns(["./first/second"])
    prune_features(['foo/bar/baaz', 'first/second', 'another_name']).should == ['./first/second']
  end

end
