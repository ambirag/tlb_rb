require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open4'
require 'tmpdir'
require 'webrick'

describe Tlb do
  URL = "http://localhost:7019"
  JOB_NAME = "foo"
  TLB_BALANCER_PORT = '9173'
  before :all do
    ENV['TLB_APP'] = 'tlb.server.TlbServerInitializer'
    server_jar = File.expand_path(Dir.glob(File.join(File.dirname(__FILE__), "tlb-server*")).first)
    klass = Tlb.balancer_process_type
    @process = klass.new("java -jar #{server_jar}")

    ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
    ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
  end

  after :all do
    Process.kill(Signal.list['KILL'], @process.instance_variable_get("@pid")) if @process.kind_of?(Tlb::ForkBalancerProcess)
    @process.instance_variable_get("@process").destroy if @process.kind_of?(Tlb::JavaBalancerProcess)
    @process.stop_pumping
  end

  describe "using server" do
    before do
      Tlb.server_running?.should be_false #precondition (the server must be started if not running)

      ENV['TLB_BALANCER_PORT'] = TLB_BALANCER_PORT
      ENV['TLB_BASE_URL'] = URL
      ENV['TYPE_OF_SERVER'] = "tlb.service.TlbServer"
      ENV['TLB_JOB_NAME'] = JOB_NAME
      ENV['TLB_TOTAL_PARTITIONS'] = '2'
      ENV['TLB_JOB_VERSION'] = '123'
      ENV['TLB_SPLITTER'] = 'tlb.splitter.CountBasedTestSplitter'
    end

    after do
      Tlb.server_running?.should be_true #api calls need not worry about killing it
      Tlb.stop_server
    end

    it "should balance for first partition" do
      ENV['TLB_PARTITION_NUMBER'] = '1'
      Tlb.start_server
      Tlb.balance_and_order(["./foo/bar.rb", "./foo/baz.rb", "./bar/foo.rb", "./bar/quux.rb"]).should == ["./foo/bar.rb", "./foo/baz.rb"]
    end

    it "should balance for second partition" do
      ENV['TLB_PARTITION_NUMBER'] = '2'
      Tlb.start_server
      Tlb.balance_and_order(["./foo/bar.rb", "./foo/baz.rb", "./bar/foo.rb", "./bar/quux.rb"]).should == ["./bar/foo.rb", "./bar/quux.rb"]
    end

    describe "thats already running" do
      before do
        Tlb.start_server
      end

      it "should publish suite result" do
        Tlb.suite_result("foo/bar.rb", true)
        Tlb.suite_result("foo/baz.rb", false)
        Tlb.suite_result("foo/quux.rb", true)
        get_from_tlb_server("suite_result").should include("foo/bar.rb: true", "foo/baz.rb: false", "foo/quux.rb: true")
      end

      it "should publish suite time" do
        Tlb.suite_time("foo/bar.rb", 102)
        Tlb.suite_time("foo/baz.rb", 3599)
        Tlb.suite_time("foo/quux.rb", 2010)
        get_from_tlb_server("suite_time").should include("foo/bar.rb: 102", "foo/baz.rb: 3599", "foo/quux.rb: 2010")
      end

      def get_from_tlb_server path
        body = Net::HTTP.get(URI.parse("#{URL}/#{JOB_NAME}/#{path}"))
        body.split("\n")
      end

      it "should use send method to balance" do
        Tlb::Balancer.expects(:send).with(Tlb::Balancer::BALANCE_PATH, "foo/bar.rb\nfoo/baz.rb").returns("foo\nbar")
        Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb"]).should == ["foo", "bar"]
      end

      it "should use send method to post results" do
        Tlb::Balancer.expects(:send).with(Tlb::Balancer::SUITE_RESULT_REPORTING_PATH, "foo/bar.rb: false")
        Tlb.suite_result("foo/bar.rb", false)
      end

      it "should use send method to post time" do
        Tlb::Balancer.expects(:send).with(Tlb::Balancer::SUITE_TIME_REPORTING_PATH, "foo/bar.rb: 42")
        Tlb.suite_time("foo/bar.rb", 42)
      end

      it "should raise exception when call to tlb fails" do
        lambda do
          Tlb::Balancer.send("/foo", "bar")
        end.should raise_error(Net::HTTPServerException, '404 "The server has not found anything matching the request URI"')
      end
    end
  end

  describe :wait_for_server_to_start do
    before do
      ENV['TLB_BALANCER_PORT'] = TLB_BALANCER_PORT
      ENV['SLEEP_BEFORE_STATUS'] = '3'
      klass = Tlb.balancer_process_type
      @mock_balancer = klass.new("#{File.join(File.dirname(__FILE__), "fixtures", "mock_balancer.rb")}")
    end

    after do
      @mock_balancer.die
    end

    it "should wait until socket has a listener" do
      before_start = Time.now
      Tlb::Balancer.wait_for_start
      Time.now.should > (before_start + 3)
    end
  end
end
