require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open4'
require 'parsedate'
require 'tmpdir'

describe Tlb do
  URL = "http://localhost:7019"
  JOB_NAME = "foo"
  before :all do
    ENV['TLB_APP'] = 'com.github.tlb.balancer.TlbServerInitializer'
    @pid, i, o, e = Open4.popen4(Tlb.server_command)
  end

  after :all do
    Process.kill(Signal.list['KILL'], @pid)
  end
  
  before do
    ENV[Tlb::TLB_OUT_FILE] = (@out_file = tmp_file('tlb_out_file').path)
    ENV[Tlb::TLB_ERR_FILE] = (@err_file = tmp_file('tlb_err_file').path)
    Tlb.server_running?.should be_false #precondition (the server must be started if not running)

    ENV['TLB_BALANCER_PORT'] = '9173'
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
    Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["foo/bar.rb", "foo/baz.rb"]
  end

  it "should balance for second partition" do
    ENV['PARTITION_NUMBER'] = '2'
    Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["bar/foo.rb", "bar/quux.rb"]
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
end
