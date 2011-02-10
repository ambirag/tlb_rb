require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper.rb')
require 'tlb/spec_task'

describe Tlb::SpecTask do
  before(:all) do
    @path_to_tlb = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'tlb'))
    @path_to_spec_formatter = File.expand_path(File.join(@path_to_tlb, 'spec_formatter'))
  end

  it "should return balanced and ordered subset" do
    @task = Tlb::SpecTask.new
    Tlb.stubs(:start_unless_running)
    @task.expects(:rspec_spec_file_list).returns(FileList['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb'])
    Tlb.stubs(:balance_and_order).with(['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb']).returns(['quux.rb', 'foo.rb'])
    balanced_list = @task.spec_file_list
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['quux.rb', 'foo.rb']
  end

  it "should hookup formatter so feedback is posted" do
    @task = Tlb::SpecTask.new
    @task.spec_opts.should == ["--require '#{@path_to_spec_formatter}' --format 'Tlb::SpecFormatter:/dev/null'"]
  end

  it "should honor user specified attributes" do
    @task = Tlb::SpecTask.new(:foo) do |t|
      t.spec_opts << "--require foo_bar"
      t.spec_opts << "--require baz_quux"
    end
    @task.spec_opts.should == ["--require '#{@path_to_spec_formatter}' --format 'Tlb::SpecFormatter:/dev/null'", "--require foo_bar", "--require baz_quux"]
    @task.name.should == :foo
  end

  it "should use specified output file for tlb's spec_formatter" do
    @task = Tlb::SpecTask.new(:foo) do |t|
      t.tlb_out = "/tmp/tlb_spec_formatter_out"
    end
    @task.spec_opts.should == ["--require '#{@path_to_spec_formatter}' --format 'Tlb::SpecFormatter:/tmp/tlb_spec_formatter_out'"]
  end
end
