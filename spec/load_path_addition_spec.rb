require File.join(File.dirname(__FILE__), 'spec_helper')

describe "load path modification" do
  before do
    @path_to_tlb_lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
  end

  it "should be enforced by tlb.rb" do
    `ruby -r#{File.join(@path_to_tlb_lib, "tlb.rb")} -e 'puts $LOAD_PATH.last'`.chomp.should == @path_to_tlb_lib
    `ruby -e 'puts $LOAD_PATH'`.chomp.should_not include(@path_to_tlb_lib)
  end
end
