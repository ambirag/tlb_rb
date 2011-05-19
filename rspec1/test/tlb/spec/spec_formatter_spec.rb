require File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'spec_helper.rb')
require 'tlb/spec/spec_formatter'
require 'spec/example/example_proxy'
require 'spec/example/example_group_proxy'

describe Tlb::SpecFormatter do
  before :all do
    FileUtils.mkdir_p(@dir = Dir.pwd + "/tmp/foo/../bar/..")
  end

  before do
    @group_1, @file_1 = stubbed_group("baz/group1")
    @group_2, @file_2 = stubbed_group("group2")
    @group_3, @file_3 = stubbed_group("group3")
    @group_proxy_1 = Spec::Example::ExampleGroupProxy.new(@group_1)
    @group_proxy_2 = Spec::Example::ExampleGroupProxy.new(@group_2)
    @group_proxy_3 = Spec::Example::ExampleGroupProxy.new(@group_3)
    @formatter = Tlb::SpecFormatter.new(nil, nil)
  end

  def stubbed_group group_name
    grp = stub(group_name)
    grp.expects(:description).returns("#{group_name} desc")
    grp.expects(:nested_descriptions).returns("#{group_name} nested desc")
    grp.expects(:example_proxies).returns("#{group_name} example proxies")
    grp.expects(:options).returns({:name => group_name})

    file_name = "#{@dir}/#{group_name}.rb"
    FileUtils.mkdir_p(File.dirname(file_name))
    File.open(file_name, 'w') do |h|
      h.write("something")
    end
    rel_file_name = File.expand_path(file_name).sub(Dir.pwd, '.')
    grp.expects(:location).times(2).returns(file_name + ":4")

    [grp, rel_file_name]
  end

  it "should be silent formatter" do
    @formatter.should be_a(Spec::Runner::Formatter::SilentFormatter)
  end

  it "should use last finished example's time" do
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 10))
    @formatter.example_group_started(@group_proxy_1)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 20))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group1 spec 1", {}, "#{@dir}/baz/group1.rb:12"))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 22))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group1 spec 2", {}, "#{@dir}/baz/group1.rb:40"), 1, "ignore")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 29))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group1 spec 3", {}, "#{@dir}/baz/group1.rb:55"), "some reason")

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 00))
    @formatter.example_group_started(@group_proxy_2)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 12))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group2 spec 1", {}, "#{@dir}/group2.rb:5"), "some reason")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 25))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group2 spec 2", {}, "#{@dir}/group2.rb:38"))

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 7, 15))
    @formatter.example_group_started(@group_proxy_3)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 12))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group3 spec 1", {}, "#{@dir}/group3.rb:45"), "some reason")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 55))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group3 spec 2", {}, "#{@dir}/group3.rb:80"), 3, "ignore")

    Tlb.stubs(:suite_result)

    Tlb.expects(:suite_time).with(@file_1, 19000)
    Tlb.expects(:suite_time).with(@file_2, 25000)
    Tlb.expects(:suite_time).with(@file_3, 100000)

    @formatter.start_dump
  end

  it "should report suite result to tlb" do
    @formatter.example_group_started(@group_proxy_1)
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group1 spec 1", {}, "#{@dir}/baz/group1.rb:12"))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group1 spec 2", {}, "#{@dir}/baz/group1.rb:40"), 1, "ignore")
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group1 spec 3", {}, "#{@dir}/baz/group1.rb:55"), "some reason")

    @formatter.example_group_started(@group_proxy_2)
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group2 spec 1", {}, "#{@dir}/group2.rb:5"), "some reason")
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group2 spec 2", {}, "#{@dir}/group2.rb:38"))

    @formatter.example_group_started(@group_proxy_3)
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group3 spec 1", {}, "#{@dir}/group3.rb:45"), "some reason")
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group3 spec 2", {}, "#{@dir}/group3.rb:80"), 3, "ignore")
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group3 spec 3", {}, "#{@dir}/group3.rb:85"))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group3 spec 4", {}, "#{@dir}/group3.rb:103"))

    Tlb.stubs(:suite_time)

    Tlb.expects(:suite_result).with(@file_1, true)
    Tlb.expects(:suite_result).with(@file_2, false)
    Tlb.expects(:suite_result).with(@file_3, true)

    @formatter.start_dump
  end

  it "should parse example_file_name" do
    @formatter.send(:example_file_name, Spec::Example::ExampleProxy.new("some method call inside spec", {}, "./spec/baz_quux.rb:9")).should == "./spec/baz_quux.rb"
    @formatter.send(:example_file_name, Spec::Example::ExampleProxy.new("some method call inside spec", {}, "./spec/foo_bar_baz.rb:9:in `should_quux'")).should == "./spec/foo_bar_baz.rb"
  end

  it "should report suite result for last heard file name when it received example_proxy having no location" do
    @formatter.example_group_started(@group_proxy_1)
    @formatter.example_failed(Spec::Example::ExampleProxy.new("before(:all)"))
    Tlb.stubs(:suite_time)

    Tlb.expects(:suite_result).with(@file_1, true)

    @formatter.start_dump
  end

  it "should share the same suite when example_group starts twice(this happens in nested describe blocks)" do
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 10))
    @formatter.example_group_started(@group_proxy_1)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 20))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group1 spec 1", {}, "#{@dir}/baz/group1.rb:12"))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 22))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group1 spec 2", {}, "#{@dir}/baz/group1.rb:40"), 1, "ignore")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 29))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group1 spec 3", {}, "#{@dir}/baz/group1.rb:55"), "some reason")

    @formatter.example_group_started(@group_proxy_1)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 12))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group1 spec 4(nested)", {}, "#{@dir}/baz/group1.rb:100"), 1, "foo_bar")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 25))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group1 spec 4(nested)", {}, "#{@dir}/baz/group1.rb:130"), "some pending")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 7, 15))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group1 spec 4(nested)", {}, "#{@dir}/baz/group1.rb:145"))

    Tlb.stubs(:suite_result)

    Tlb.expects(:suite_time).with(@file_1, 125000)
    @formatter.start_dump
  end

end
