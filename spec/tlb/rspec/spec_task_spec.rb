require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'spec_task'

describe Tlb::RSpec::SpecTask do

  it "should return balanced and ordered subset" do
    @task = Tlb::RSpec::SpecTask.new
    Tlb.stubs(:start_unless_running)
    @task.expects(:rspec_files_to_run).returns(FileList['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb'])
    Tlb.stubs(:balance_and_order).with(['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb']).returns(['quux.rb', 'foo.rb'])
    balanced_list = @task.files_to_run
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['quux.rb', 'foo.rb']
  end
end
