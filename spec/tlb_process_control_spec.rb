require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
require 'open4'
require 'tmpdir'

describe Tlb do
  before do
    ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
    ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
  end

  describe "mock test" do
    before do
      Tlb::Balancer.stubs(:wait_for_start)
    end

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

  describe "for balancer sub-process" do
    before do
      Tlb.expects(:server_command).returns(File.join(File.dirname(__FILE__), "fixtures", "mock_balancer.rb"))
      ENV[Tlb::Balancer::TLB_BALANCER_PORT] = 9071.to_s

      ENV['foo_bar'] = 'baz_quux' #some ramdom variables for sub-process env-var assertion
      ENV['TLB_SPLITTER'] = 'foo.bar.baz.Quux'

      Tlb.start_server

      @after_stop = proc { }
    end

    after do
      Tlb.stop_server
      File.read(@err_file).should include("Suicide called")
      @after_stop.call
    end

    it "should pump error and output stream out to the corresponding files" do
      Tlb::Balancer.get("/echo").should == "" #assertion in after(is flaky if assertions are kept here
      @after_stop = proc do
        File.read(@out_file).should include("'Hello World!' to stdout")
        File.read(@err_file).should include("'Hello World!' to stderr")
      end
    end

    it "should set environment variables before launching the sub-process" do
      body = Tlb::Balancer.get('/env/dump')
      sub_process_env = YAML.load(body)
      sub_process_env['foo_bar'].should == 'baz_quux'
      sub_process_env['TLB_SPLITTER'].should == 'foo.bar.baz.Quux'
    end
  end
end
