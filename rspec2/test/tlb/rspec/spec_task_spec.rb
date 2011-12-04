require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'tlb/rspec/spec_task'

describe Tlb::RSpec::SpecTask do
  before(:all) do
    @path_to_reporter_inflection = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'tlb', 'rspec', 'reporter_inflection'))
  end

  def spec_files_pattern
    spec_dir_path = File.join("tmp", "tlb_rb_spec_dir")
    FileUtils.rm_rf spec_dir_path
    spec_dir = FileUtils.mkdir_p spec_dir_path
    FileUtils.touch File.join(spec_dir_path, "foo.rb")
    FileUtils.touch File.join(spec_dir_path, "bar.rb")
    FileUtils.touch File.join(spec_dir_path, "baz.rb")
    FileUtils.touch File.join(spec_dir_path, "quux.rb")
    inner_dir_path = File.join(spec_dir_path, "inner", "dir")
    FileUtils.mkdir_p inner_dir_path
    FileUtils.touch File.join(inner_dir_path, "hello.rb")
    File.join(spec_dir_path, "**/*.rb")
  end

  it "should return balanced and ordered subset by tlb-style[./dir/file_spec.rb] relative file names" do
    @task = Tlb::RSpec::SpecTask.new
    Tlb.stubs(:start_unless_running)
    @task.pattern = spec_files_pattern
    Tlb.stubs(:balance_and_order).with(['./tmp/tlb_rb_spec_dir/baz.rb', './tmp/tlb_rb_spec_dir/quux.rb', './tmp/tlb_rb_spec_dir/foo.rb', './tmp/tlb_rb_spec_dir/bar.rb', './tmp/tlb_rb_spec_dir/inner/dir/hello.rb'], nil).returns(['./tmp/tlb_rb_spec_dir/inner/dir/hello.rb', './tmp/tlb_rb_spec_dir/foo.rb'])
    balanced_list = @task.files_to_run
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['./tmp/tlb_rb_spec_dir/inner/dir/hello.rb', './tmp/tlb_rb_spec_dir/foo.rb']
  end

  it "should report configured tlb-module-name to balance-and-reorder call" do
    @task = Tlb::RSpec::SpecTask.new
    @task.tlb_module_name = 'my-rspec2-module'
    Tlb.stubs(:start_unless_running)
    @task.pattern = spec_files_pattern
    Tlb.stubs(:balance_and_order).with(['./tmp/tlb_rb_spec_dir/baz.rb', './tmp/tlb_rb_spec_dir/quux.rb', './tmp/tlb_rb_spec_dir/foo.rb', './tmp/tlb_rb_spec_dir/bar.rb', './tmp/tlb_rb_spec_dir/inner/dir/hello.rb'], 'my-rspec2-module').returns(['./tmp/tlb_rb_spec_dir/inner/dir/hello.rb', './tmp/tlb_rb_spec_dir/foo.rb'])
    balanced_list = @task.files_to_run
    balanced_list.should be_a(Rake::FileList)
    balanced_list.to_a.should == ['./tmp/tlb_rb_spec_dir/inner/dir/hello.rb', './tmp/tlb_rb_spec_dir/foo.rb']
  end

  it "should hookup formatter so feedback is posted" do
    @task = Tlb::RSpec::SpecTask.new
    @task.rspec_opts.should == " --require '#{@path_to_reporter_inflection}' "
  end

  it "should honor user specified attributes" do
    @task = Tlb::RSpec::SpecTask.new(:foo) do |t|
      t.rspec_opts = "--require foo_bar"
      t.rspec_opts += " --require baz_quux"
    end
    @task.rspec_opts.should == " --require '#{@path_to_reporter_inflection}' --require foo_bar --require baz_quux"
    @task.name.should == :foo
  end

end
