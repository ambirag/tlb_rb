require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'open4'
require 'tmpdir'

describe Tlb do
  before do
    ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
    ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
    Tlb::Balancer.stubs(:wait_for_start)
  end

  MOCK_PROCESS_ID = 33040
  SIG_TERM = 15

  it "should terminate process when stop called" do
    Tlb.instance_variable_set('@balancer_process', bal_process = mock('balancer_process'))
    bal_process.expects(:die)

    Tlb.stop_server
  end

  it "should generate the right command to run tlb balancer server" do
    tlb_jar = File.expand_path(Dir.glob(File.join(File.join(File.dirname(__FILE__), ".."), "tlb-alien*")).first)
    Tlb.server_command.should == "java -jar #{tlb_jar}"
  end

  it "should fail of server not running" do
    Tlb.expects(:server_running?).returns(false)
    lambda { Tlb.ensure_server_running }.should raise_error('Balancer server must be started before tests are run.')
  end

  it "should not start server if running" do
    Tlb.expects(:server_running?).returns(true)
    Tlb.expects(:start_server).never
    Tlb.ensure_server_running
  end
end
