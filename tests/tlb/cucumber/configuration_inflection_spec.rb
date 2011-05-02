require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'tlb/cucumber/configuration_inflection'

describe Tlb::Cucumber::ConfigurationInflection do
  it "should be included in cucumber-cli-configuration" do
    Cucumber::Cli::Configuration.included_modules.should include(Tlb::Cucumber::ConfigurationInflection)
  end

  it "should call splitter and observer on run_suite when included" do
    mediator = Class.new do
      attr_accessor :feature_files_called
      def feature_files
        @feature_files_called = true
        :foo
      end
      include Tlb::Cucumber::ConfigurationInflection
    end.new

    mediator.expects(:prune_features).returns(:foo) do
      mediator.feature_files_called.should be_false
    end
    mediator.feature_files.should == :foo
    mediator.feature_files_called.should be_true
  end
end
