require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'spec_task_enhancement'

describe Tlb::SpecTaskEnhancement do
  before do
    @klass = Class.new do
      def files_to_run
        FileList['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb']
      end
      include Tlb::SpecTaskEnhancement
    end
  end

  it "should return balanced and ordered subset" do
    Tlb.stubs(:balance_and_order).with(['foo.rb', 'bar.rb', 'baz.rb', 'quux.rb']).returns(['quux.rb', 'foo.rb'])
    balanced_list = @klass.new.files_to_run
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['quux.rb', 'foo.rb']
  end

  it "should not enhance class if no spec_file_list method is present" do
    begin
      Class.new do
        include Tlb::SpecTaskEnhancement
      end
    rescue Exception => e
      e.message.should =~ /undefined method `files_to_run' for class /
    end
  end
end
