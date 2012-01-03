require File.join(File.dirname(__FILE__), 'spec_helper')
require 'tlb'
require 'open4'
require 'tmpdir'
require 'webrick'
require 'tlb'

describe Tlb do
  URL = "http://localhost:7019"
  JOB_NAME = "foo"
  TLB_BALANCER_PORT = '9173'

  before :all do
    ENV['TLB_APP'] = 'tlb.server.TlbServerInitializer'
    server_jar = File.expand_path(Dir.glob(File.join(File.dirname(__FILE__), "tlb-server*")).first)
    klass = Tlb.balancer_process_type
    @process = klass.new("java -jar #{server_jar}")
  end

  after :all do
    Process.kill(Signal.list['KILL'], @process.instance_variable_get("@pid")) if @process.kind_of?(Tlb::ForkBalancerProcess)
    @process.instance_variable_get("@process").destroy if @process.kind_of?(Tlb::JavaBalancerProcess)
    @process.stop_pumping
  end

  def uncaught_exception message
    "uncaught throw " + (RUBY_VERSION == "1.8.7" ? "`#{message.gsub('\n', '
')}'" : ('"' + message.gsub(/"/, '\"') + '"'))
  end

  describe "out and err file defaulting" do
    before do
      Tlb.server_running?.should be_false #precondition (the server must be started if not running)

      ENV['TLB_BALANCER_PORT'] = TLB_BALANCER_PORT
      ENV['TLB_BASE_URL'] = URL
      ENV['TYPE_OF_SERVER'] = "tlb.service.TlbServer"
      ENV['TLB_JOB_NAME'] = JOB_NAME
      ENV['TLB_TOTAL_PARTITIONS'] = '2'
      ENV['TLB_JOB_VERSION'] = '123'
      ENV['TLB_SPLITTER'] = 'tlb.splitter.CountBasedTestSplitter'
      ENV.delete('SPLIT_CORRECTNESS_CHECKER')
      ENV.delete(Tlb::TLB_OUT_FILE)
      ENV.delete(Tlb::TLB_ERR_FILE)
    end

    after do
      Tlb.server_running?.should be_true #api calls need not worry about killing it
      Tlb.stop_server
    end

    it "should balance for first partition" do
      ENV['TLB_PARTITION_NUMBER'] = '1'
      Tlb.start_server
      Tlb.balance_and_order(["./foo/bar.rb", "./foo/baz.rb", "./bar/foo.rb", "./bar/quux.rb"]).should == ["./foo/bar.rb", "./foo/baz.rb"]
      File.exists?(File.join(Dir.pwd, Tlb::TLB_OUT_FILE.downcase)).should be_true
      File.exists?(File.join(Dir.pwd, Tlb::TLB_ERR_FILE.downcase)).should be_true
    end
  end

  describe "everything" do

    before :all do
      ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
      ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
    end

    it "should use default balancer-port if none given" do
      ENV['TLB_BALANCER_PORT'] = nil
      Tlb::Balancer.port.should == '8019'
      ENV['TLB_BALANCER_PORT'] = '9898'
      Tlb::Balancer.port.should == '9898'
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

      describe :correctness_check do
        before do
          ENV['TLB_JOB_NAME'] = Object.new.object_id.to_s
          ENV['SPLIT_CORRECTNESS_CHECKER'] = 'tlb.splitter.correctness.AbortOnFailure'
        end

        after do
          ENV.delete('SPLIT_CORRECTNESS_CHECKER')
        end

        it "should perform correctness check when enabled and RAISE EXCEPTION when check FAILS" do
          begin
            ENV['TLB_PARTITION_NUMBER'] = '1'
            Tlb.start_server
            Tlb.balance_and_order(["./foo/bar.rb", "./foo/baz.rb", "./bar/foo.rb", "./bar/quux.rb"])
          ensure
            Tlb.stop_server
          end
          ENV['TLB_PARTITION_NUMBER'] = '2'
          Tlb.start_server
          partition_2 = nil
          exception = nil
          lambda do
            partition_2 = Tlb.balance_and_order(["./bar/quux.rb"])
          end.should raise_error(uncaught_exception('417 "Correctness validation failed" Details: { Expected universal set was [./bar/foo.rb, ./bar/quux.rb, ./foo/bar.rb: 1/2, ./foo/baz.rb: 1/2] but given [./bar/quux.rb].\n }'))
          partition_2.should be_nil
        end

        it "should NOT raise exception when correctness check is enabled but it PASSES" do
          begin
            ENV['TLB_PARTITION_NUMBER'] = '1'
            Tlb.start_server
            Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"])
          ensure
            Tlb.stop_server
          end
          ENV['TLB_PARTITION_NUMBER'] = '2'
          Tlb.start_server
          Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"]).should_not be_nil
        end

        it "should FAIL all-partitions-executed assertion if NOT all partitions have run" do
          ENV['TLB_PARTITION_NUMBER'] = '2'
          Tlb.start_server
          Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"])
          lambda do
            Tlb.assert_all_partitions_executed
          end.should raise_error(uncaught_exception('417 "Correctness validation failed" Details: { - [1] of total 2 partition(s) were not executed. This violates collective exhaustion. Please check your partition configuration for potential mismatch in total-partitions value and actual \'number of partitions\' configured and check your build process triggering mechanism for failures.\n }'))
        end

        it "should NOT fail all-partitions-executed assertion if all partitions have run" do
          begin
            ENV['TLB_PARTITION_NUMBER'] = '1'
            Tlb.start_server
            Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"])
          ensure
            Tlb.stop_server
          end
          ENV['TLB_PARTITION_NUMBER'] = '2'
          Tlb.start_server
          Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"])
          Tlb.assert_all_partitions_executed.should == "All partitions executed.\n"
        end

        it "should NOT fail all-partitions-executed assertion for other modules when some module didn't run all partitions" do
          begin
            ENV['TLB_PARTITION_NUMBER'] = '1'
            Tlb.start_server
            Tlb.balance_and_order(["./foo/baz.rb", "./bar/quux.rb"], 'module-bar')
          ensure
            Tlb.stop_server
          end
          begin
            ENV['TLB_PARTITION_NUMBER'] = '1'
            Tlb.start_server
            Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"], 'module-foo')
          ensure
            Tlb.stop_server
          end
          ENV['TLB_PARTITION_NUMBER'] = '2'
          Tlb.start_server
          Tlb.balance_and_order(["./foo/bar.rb", "./bar/quux.rb"], 'module-foo')

          Tlb.assert_all_partitions_executed('module-foo') #should not fail

          lambda do
            Tlb.assert_all_partitions_executed('module-bar') #must fail, as only first partitions was executed of 2
          end.should raise_error(uncaught_exception('417 "Correctness validation failed" Details: { - [2] of total 2 partition(s) were not executed. This violates collective exhaustion. Please check your partition configuration for potential mismatch in total-partitions value and actual \'number of partitions\' configured and check your build process triggering mechanism for failures.\n }'))
        end
      end

      describe "thats already running" do
        before do
          ENV['TLB_PARTITION_NUMBER'] = '1'
          Tlb.start_server
          Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "foo/quux.rb", "one.rb", "two.rb", "three.rb"]).should include("foo/bar.rb", "foo/baz.rb", "foo/quux.rb")
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
          Tlb::Balancer.expects(:send).with(Tlb::Balancer::BALANCE_PATH, "foo/bar.rb\nfoo/baz.rb", { }).returns("foo\nbar")
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
          end.should raise_error(uncaught_exception('404 "The server has not found anything matching the request URI" Details: { <html>\n<head>\n   <title>Status page</title>\n</head>\n<body>\n<h3>The server has not found anything matching the request URI</h3><p>You can get technical details <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.5">here</a>.<br>\nPlease continue your visit at our <a href="/">home page</a>.\n</p>\n</body>\n</html>\n }'))
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
end
