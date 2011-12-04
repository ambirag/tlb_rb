require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'tlb'
require 'tlb/arg_processor'

describe Tlb::ArgProcessor do
  PRINT_ARGUMENTS_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'print_arguments.rb'))
  PRINT_ALL_PROCESSED_ARGS_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'print_all_processed_args.rb'))

  before do
    Tlb::ArgProcessor.reset!
  end

  after do
    Tlb::ArgProcessor.reset!
  end

  it "should load arguments given anywhere in the command line" do
    output = `ruby -I#{$core_lib} -r#{PRINT_ARGUMENTS_FILE} -r#{Tlb::ArgProcessor::FILE} #{PRINT_ARGUMENTS_FILE} -Arg:foo=bar -Arg:baz=quux hello -Arg:bar=baz buffalo! -Arg:bang=boom`

    output_lines = output.split("\n")

    output_lines.grep(/LOAD 0 ARGUMENTS/).first.should include("-Arg:foo=bar -Arg:baz=quux hello -Arg:bar=baz buffalo! -Arg:bang=boom")
    output_lines.grep(/LOAD 1 ARGUMENTS/).first.should include("hello buffalo!")
  end

  it "should store all parsed arguments" do
    output = `ruby -I#{$core_lib} -r#{Tlb::ArgProcessor::FILE} #{PRINT_ALL_PROCESSED_ARGS_FILE} -Arg:foo=bar hello buffalo! -Arg:baz=quux`
    output.should == "baz=quux\nfoo=bar\n"
  end

  it "should return the value of argument when requested" do
    ARGV << "-Arg:foo=bar"
    ARGV << "-Arg:baz=quux"
    Tlb::ArgProcessor.parse!
    Tlb::ArgProcessor.val('foo').should == "bar"
    Tlb::ArgProcessor.val(:baz).should == "quux"
  end
end
