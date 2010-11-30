require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
require 'tlb/rspec/spec_formatter'
require 'rspec/core/example'
require 'rspec/core/metadata'
require 'rspec/core/example_group'

describe Tlb::RSpec::SpecFormatter do
  before :all do
    FileUtils.mkdir_p(@dir = Dir.pwd + "/tmp/foo/../bar/..")
  end

  before do
    group_1_file, @file_1 = stubbed_group("baz/group1")
    group_2_file, @file_2 = stubbed_group("group2")
    group_3_file, @file_3 = stubbed_group("group3")
    @group_proxy_1 = RSpec::Core::ExampleGroup.describe("group1")
    @group_proxy_1.instance_variable_set('@metadata', RSpec::Core::Metadata.new().process('parent group 1', :caller => ["#{group_1_file}:5"]))
    @group_proxy_2 = RSpec::Core::ExampleGroup.describe("group2")
    @group_proxy_2.instance_variable_set('@metadata', RSpec::Core::Metadata.new().process('parent group 2', :caller => ["#{group_2_file}:3"]))
    @group_proxy_3 = RSpec::Core::ExampleGroup.describe("group3")
    @group_proxy_3.instance_variable_set('@metadata', RSpec::Core::Metadata.new().process('parent group 3', :caller => ["#{group_3_file}:9"]))
    @formatter = Tlb::RSpec::SpecFormatter.new(nil)
  end

  def stubbed_group group_name
    file_name = "#{@dir}/#{group_name}.rb"
    FileUtils.mkdir_p(File.dirname(file_name))
    File.open(file_name, 'w') do |h|
      h.write("something")
    end
    rel_file_name = File.expand_path(file_name).sub(Dir.pwd, '.')
    [file_name, rel_file_name]
  end

  it "should be silent formatter" do
    @formatter.should be_a(RSpec::Core::Formatters::BaseFormatter)
  end

  it "should use last finished example's time" do
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 10))
    @formatter.example_group_started(@group_proxy_1)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 20))
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_1, "foo bar", {:caller => "#{@dir}/baz/group1.rb:12"}))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 22))
    @formatter.example_failed(RSpec::Core::Example.new(@group_proxy_1, "baz quux", {:caller => "#{@dir}/baz/group1.rb:40"}))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 29))
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_1, "quux bang", {:caller => "#{@dir}/baz/group1.rb:55"}))

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 00))
    @formatter.example_group_started(@group_proxy_2)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 12))
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_2, "hello", {:caller => "#{@dir}/group2.rb:5"}))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 25))
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_2, "world", {:caller => "#{@dir}/group2.rb:38"}))

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 7, 15))
    @formatter.example_group_started(@group_proxy_3)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 12))
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_3, "hi", {:caller => "#{@dir}/group3.rb:45"}))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 55))
    @formatter.example_failed(RSpec::Core::Example.new(@group_proxy_3, "there", {:caller => "#{@dir}/group3.rb:80"}))

    Tlb.stubs(:suite_result)

    Tlb.expects(:suite_time).with(@file_1, 19000)
    Tlb.expects(:suite_time).with(@file_2, 25000)
    Tlb.expects(:suite_time).with(@file_3, 100000)

    @formatter.start_dump
  end

  it "should report suite result" do
    @formatter.example_group_started(@group_proxy_1)
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_1, "some line 12", {:caller => "#{@dir}/baz/group1.rb:12"}))
    @formatter.example_failed(RSpec::Core::Example.new(@group_proxy_1, "some line 40", {:caller => "#{@dir}/baz/group1.rb:40"}))
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_1, "some line 55", {:caller => "#{@dir}/baz/group1.rb:55"}))

    @formatter.example_group_started(@group_proxy_2)
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_2, "some line 5", {:caller => "#{@dir}/group2.rb:5"}))
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_2, "some line 38", {:caller => "#{@dir}/group2.rb:38"}))

    @formatter.example_group_started(@group_proxy_3)
    @formatter.example_pending(RSpec::Core::Example.new(@group_proxy_3, "some line 45", {:caller => "#{@dir}/group3.rb:45"}))
    @formatter.example_failed(RSpec::Core::Example.new(@group_proxy_3, "some line 80", {:caller => "#{@dir}/group3.rb:80"}))
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_3, "some line 85", {:caller => "#{@dir}/group3.rb:85"}))
    @formatter.example_passed(RSpec::Core::Example.new(@group_proxy_3, "some line 103", {:caller => "#{@dir}/group3.rb:103"}))

    Tlb.stubs(:suite_time)

    Tlb.expects(:suite_result).with(@file_1, true)
    Tlb.expects(:suite_result).with(@file_2, false)
    Tlb.expects(:suite_result).with(@file_3, true)

    @formatter.start_dump
  end
end
