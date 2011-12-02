require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'tlb/test_unit/test_task'

describe Tlb::TestUnit::TestTask do
  before :all do
    @path_to_mediator_inflection = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'tlb', 'test_unit', 'mediator_inflection'))
  end

  it "should be a rake-testtask" do
    Tlb::TestUnit::TestTask.superclass.should == Rake::TestTask
  end

  it "should inject require of mediator_inflection in ruby opts" do
    test_task = Tlb::TestUnit::TestTask.new do |t|
      t.libs << "foo"
      t.test_files = ['test/foo_test.rb', 'test/bar_test.rb', 'test/baz_test.rb']
      t.verbose = true
    end

    test_task.ruby_opts.should == [" -r'#{Tlb::ArgProcessor::FILE}' ", " -r'#{@path_to_mediator_inflection}' "]
    test_task.libs.should include("foo")
    test_task.instance_variable_get('@test_files').should == ['test/foo_test.rb', 'test/bar_test.rb', 'test/baz_test.rb']
    test_task.verbose.should be_true
  end

  it "should prepend to existing ruby_opts" do
    test_task = Tlb::TestUnit::TestTask.new do |t|
      t.test_files = ['test/foo_test.rb', 'test/bar_test.rb', 'test/baz_test.rb']
      t.ruby_opts << " -Ifoo/bar "
      t.ruby_opts << " -rbaz/quux "
    end

    test_task.ruby_opts.should == [" -r'#{Tlb::ArgProcessor::FILE}' ",
                                   " -r'#{@path_to_mediator_inflection}' ",
                                   " -Ifoo/bar ",
                                   " -rbaz/quux "]
  end

  it "should use given name" do
    Tlb::TestUnit::TestTask.new(:foo_bar).name.should == :foo_bar
  end

  it "should set module name as environment variable when given" do
    test_task = Tlb::TestUnit::TestTask.new(:task_with_module_name) do |t|
      t.tlb_module_name = 'foo_bar_module'
      t.test_files = [DUMP_ENV_RUBY_SCRIPT]
    end
    test_task.option_list.should include("-Arg:tlb_module_name=foo_bar_module")
  end

  it "should not set tlb_module_name when not given" do
    test_task = Tlb::TestUnit::TestTask.new do |t|
    end
    test_task.option_list.should_not include("-Arg:tlb_module_name")
  end
end
