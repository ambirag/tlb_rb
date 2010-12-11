require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'tlb/rspec/spec_task'

describe Tlb::RSpec::SpecTask do
  before(:all) do
    @path_to_tlb = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'tlb'))
    @path_to_reporter_inflection = File.expand_path(File.join(@path_to_tlb, 'rspec', 'reporter_inflection'))
  end

  it "should return balanced and ordered subset" do
    @task = Tlb::RSpec::SpecTask.new
    Tlb.stubs(:start_unless_running)
    @task.expects(:rspec_files_to_run).returns(FileList['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb'])
    Tlb.stubs(:balance_and_order).with(['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb']).returns(['quux.rb', 'foo.rb'])
    balanced_list = @task.files_to_run
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['quux.rb', 'foo.rb']
  end

  it "should hookup formatter so feedback is posted" do
    @task = Tlb::RSpec::SpecTask.new
    @task.rspec_opts.should == " --require #{@path_to_tlb} --require tlb/rspec/reporter_inflection "
  end

  it "should honor user specified attributes" do
    @task = Tlb::RSpec::SpecTask.new(:foo) do |t|
      t.rspec_opts = "--require foo_bar"
      t.rspec_opts += " --require baz_quux"
    end
    @task.rspec_opts.should == " --require #{@path_to_tlb} --require tlb/rspec/reporter_inflection --require foo_bar --require baz_quux"
    @task.name.should == :foo
  end
end
