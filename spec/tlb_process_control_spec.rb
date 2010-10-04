require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open4'
require 'parsedate'
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
    Tlb.instance_variable_set('@pid', MOCK_PROCESS_ID)
    Tlb.instance_variable_set('@out_pumper', Thread.new { })
    Tlb.instance_variable_set('@err_pumper', Thread.new { })

    Process.expects(:kill).with(SIG_TERM, MOCK_PROCESS_ID)

    Tlb.stop_server
  end

  def times_of_output content, stream_name
    content.split("\n").map { |line| line.gsub(stream_name, '') }.map do |line|
      year, month, day_of_month, hour, minute, second, timezone, day_of_week = ParseDate.parsedate(line)
      Time.local(year, month, day_of_month, hour, minute, second)
    end
  end

  it "should generate the right command to run tlb balancer server" do
    tlb_jar = File.expand_path(Dir.glob(File.join(File.join(File.dirname(__FILE__), ".."), "tlb-all*")).first)
    Tlb.server_command.should == "java -jar #{tlb_jar}"
  end

  describe :integration_test do
    it "should pump both error and out to the file" do
      Tlb.expects(:server_command).returns(File.join(File.dirname(__FILE__), "fixtures", "foo.sh"))
      Tlb.server_running?.should be_false
      Tlb.start_server
      Tlb.server_running?.should be_true
      sleep 2
      Tlb.server_running?.should be_true
      Tlb.stop_server
      Tlb.server_running?.should be_false
      File.read(@out_file).should include("hello out\n")
      File.read(@err_file).should include("hello err\n")
    end
  end

  it "should start server if not running" do
    Tlb.expects(:server_running?).returns(false)
    Tlb.expects(:start_server)
    Tlb.ensure_server_running
  end

  it "should not start server if running" do
    Tlb.expects(:server_running?).returns(true)
    Tlb.expects(:start_server).never
    Tlb.ensure_server_running
  end

  describe "env var" do
    before do
      module Open4
        class << self
          alias_method :old_popen4, :popen4
        end

        def self.popen4 command
          ENV['TLB_APP'].should == "com.github.tlb.balancer.BalancerInitializer"
        end
      end
    end

    after do
      module Open4
        class << self
          alias_method :popen4, :old_popen4
        end
      end
    end

    it "should set TLB_APP to point to balancer before starting the server" do
      ENV['TLB_APP'] = "foo"
      Tlb.stubs(:server_command).returns("foo bar")
      Tlb.start_server
    end
  end
end
