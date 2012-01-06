require File.join(File.dirname(__FILE__), 'spec_helper')

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'tlb_server_runner'))
require 'stringio'

describe TlbServerRunner do
  it "should execute the given command" do
    runner = TlbServerRunner.new
    say_foo_file = File.join(File.dirname(__FILE__), "say_foo.sh")
    runner.expects(:exec_file).returns(say_foo_file)
    Kernel.expects(:system).with("/bin/bash #{say_foo_file} bar")
    `echo foo` #so $? is set to success
    runner.bar
  end

  it "should fail when underlying command returns non-zero exit code" do
    runner = TlbServerRunner.new
    say_foo_file = File.join(File.dirname(__FILE__), "say_foo.sh")
    runner.expects(:exec_file).returns(say_foo_file)
    Kernel.expects(:system).with("/bin/bash #{say_foo_file} bar")
    begin
      `some_unknown_command with_unknown_arg` #so $? is set to failure
    rescue
    end
    ex = nil
    begin
      runner.bar
    rescue
      ex = $!
    end
    ex.message.should == uncaught_exception("'/bin/bash #{say_foo_file} bar' failed, please check stdout or stderr files.")
  end
end
