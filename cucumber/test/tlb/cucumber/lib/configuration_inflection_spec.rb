require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/lib/configuration_inflection'
require 'tlb/cucumber/lib/run_data_formatter'

describe Tlb::Cucumber::Lib::ConfigurationInflection do
  it "should be included in cucumber-cli-configuration" do
    Cucumber::Cli::Configuration.included_modules.should include(Tlb::Cucumber::Lib::ConfigurationInflection)
  end

  it "should call prune features when all features are obtained" do
    mediator = Class.new do
      attr_accessor :feature_files_called
      def feature_files
        @feature_files_called = true
        :foo
      end

      def formatters(not_used)
      end

      include Tlb::Cucumber::Lib::ConfigurationInflection
    end.new

    mediator.expects(:prune_features).returns(:foo) do
      mediator.feature_files_called.should be_false
    end
    mediator.feature_files.should == :foo
    mediator.feature_files_called.should be_true
  end

  it "should add RunDataFormatter as a formatter" do
    mediator = Class.new do
      def feature_files
        :foo
      end

      def formatters(does_not_matter)
        [:formatter_one]
      end
      include Tlb::Cucumber::Lib::ConfigurationInflection
    end.new

    formatters = mediator.formatters("ignore")
    formatters.size.should == 2
    formatters.first.should == :formatter_one
    formatters.last.class.should == Tlb::Cucumber::Lib::RunDataFormatter
  end

  it "should not inflect if it already has" do
    mediator = Class.new do
      def feature_files
        :foo
      end

      def formatters(does_not_matter)
        [:formatter_one]
      end
      include Tlb::Cucumber::Lib::ConfigurationInflection
    end.new

    formatters = mediator.formatters("ignore")
    formatters.size.should == 2

    class << mediator
      include Tlb::Cucumber::Lib::ConfigurationInflection
    end

    formatters = mediator.formatters("ignore")
    formatters.size.should == 2
  end

  it "should point to the correct inflection file name" do
    Tlb::Cucumber::Lib::ConfigurationInflection::FILE.should == File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', 'lib', 'tlb', 'cucumber', 'lib', 'configuration_inflection.rb'))
  end
end
