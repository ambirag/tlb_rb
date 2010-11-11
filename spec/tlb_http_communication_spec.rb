require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open4'
require 'parsedate'
require 'tmpdir'
require 'webrick'

describe Tlb do
  URL = "http://localhost:7019"
  JOB_NAME = "foo"
  TLB_BALANCER_PORT = '9173'
  before :all do
    ENV['TLB_APP'] = 'com.github.tlb.server.TlbServerInitializer'
    @pid, i, o, e = Open4.popen4(Tlb.server_command)
  end

  after :all do
    Process.kill(Signal.list['KILL'], @pid)
  end

  it "should wait for balancer server to come up before returning from start_server" do
    Tlb::Balancer.expects(:wait_for_start)
    Open4.stubs(:popen4)
    Tlb.start_server
  end

  describe "using server" do
    before do
      ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
      ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
      Tlb.server_running?.should be_false #precondition (the server must be started if not running)

      ENV['TLB_BALANCER_PORT'] = TLB_BALANCER_PORT
      ENV['TLB_URL'] = URL
      ENV['TALK_TO_SERVICE'] = "com.github.tlb.service.TalkToTlbServer"
      ENV['TLB_JOB_NAME'] = JOB_NAME
      ENV['TOTAL_PARTITIONS'] = '2'
      ENV['JOB_VERSION'] = '123'
      ENV['TLB_CRITERIA'] = 'com.github.tlb.splitter.CountBasedTestSplitterCriteria'
    end

    after do
      Tlb.server_running?.should be_true #api calls need not worry about killing it
      Tlb.stop_server
    end

    it "should balance for first partition" do
      ENV['PARTITION_NUMBER'] = '1'
      Tlb.start_server
      Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["./foo/bar.rb", "./foo/baz.rb"]
    end

    it "should balance for second partition" do
      ENV['PARTITION_NUMBER'] = '2'
      Tlb.start_server
      Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["./bar/foo.rb", "./bar/quux.rb"]
    end

    it "should balance with file path names relative to working dir" do
      ENV['PARTITION_NUMBER'] = '1'
      Tlb.start_server
      Tlb.balance_and_order(["foo/hi/../baz/quux/../hello/../../bar.rb", "foo/bar/../baz.rb", "bar/baz/quux/../../foo.rb", "bar/quux.rb"]).should == ["./foo/bar.rb", "./foo/baz.rb"]
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
        Tlb::Balancer.expects(:send).with(Tlb::Balancer::BALANCE_PATH, "./foo/bar.rb\n./foo/baz.rb").returns("foo\nbar")
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
    class CtrlStatus < WEBrick::HTTPServlet::AbstractServlet
      def do_GET(request, response)
        response.status = 200
        response['Content-Type'] = 'text/plain'
        response.body = 'RUNNING'
      end
    end
    before do
      @server = nil
      ENV['TLB_BALANCER_PORT'] = TLB_BALANCER_PORT
    end

    after do
      @server.shutdown
    end

    it "should wait until socket has a listener" do
      @wait_completed = false
      before_start = Time.now
      wait_thread = Thread.new do
        sleep 3
        @wait_completed = true
        @server = WEBrick::HTTPServer.new(:Port => TLB_BALANCER_PORT,
                                          :Logger => WEBrick::BasicLog.new(tmp_file('tlb_webrick_log').path),
                                          :AccessLog => WEBrick::BasicLog.new(tmp_file('tlb_webrick_access_log').path))
        @server.mount '/control/status', CtrlStatus
        @server.start
      end
      @wait_completed.should be_false
      Tlb::Balancer.wait_for_start
      @wait_completed.should be_true
      Time.now.should > (before_start + 3)
    end
  end
end
