require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open4'
require 'parsedate'
require 'tmpdir'

describe Tlb do
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
    ENV['TLB_URL'] = "http://localhost:7019"
    ENV['TALK_TO_SERVICE'] = "com.github.tlb.service.TalkToTlbServer"
    ENV['TLB_JOB_NAME'] = "foo"
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
    Tlb.ensure_server_running
    Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["foo/bar.rb", "foo/baz.rb"]
  end

  it "should balance for second partition" do
    ENV['PARTITION_NUMBER'] = '2'
    Tlb.ensure_server_running
    Tlb.balance_and_order(["foo/bar.rb", "foo/baz.rb", "bar/foo.rb", "bar/quux.rb"]).should == ["bar/foo.rb", "bar/quux.rb"]
  end
end
