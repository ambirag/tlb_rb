require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/lib/run_data_formatter'
require 'cucumber/ast/feature'

describe Tlb::Cucumber::Lib::RunDataFormatter do

  before do
    @formatter = Tlb::Cucumber::Lib::RunDataFormatter.new()
    Cucumber::WINDOWS = false unless defined? Cucumber::WINDOWS
    @feature = Cucumber::Ast::Feature.new(nil, nil, nil, nil, "Subtraction", nil)
    @feature.file = "./features/sub.feature"
  end

  it "should start a tlb suite capture when the feature starts to execute" do
    @formatter.expects(:suite_started).with("./features/sub.feature")

    @formatter.before_feature(@feature)
  end

  it "should update feature as failed if a step reports as non-passing" do
    @formatter.expects(:update_suite_failed).with("./features/sub.feature")

    @formatter.before_feature(@feature)
    @formatter.after_step_result(nil, nil, nil, :passed, nil, nil, nil)
    @formatter.after_step_result(nil, nil, nil, :failed, nil, nil, nil)
    @formatter.after_feature(@feature)
  end

  it "should not update the feature as failed if all steps pass" do
    enhance_formatter
    @formatter.before_feature(@feature)
    @formatter.after_step_result(nil, nil, nil, :passed, nil, nil, nil)
    @formatter.after_feature(@feature)

    @formatter.update_called.should be_false
  end

  it "should not update the feature as failed if steps are pending" do
    enhance_formatter
    @formatter.before_feature(@feature)
    @formatter.after_step_result(nil, nil, nil, :passed, nil, nil, nil)
    @formatter.after_step_result(nil, nil, nil, :pending, nil, nil, nil)
    @formatter.after_step_result(nil, nil, nil, :passed, nil, nil, nil)
    @formatter.after_feature(@feature)

    @formatter.update_called.should be_false
  end

  it "should update feature data once the feature is complete" do
    @formatter.expects(:update_suite_failed).with("./features/sub.feature")
    @formatter.expects(:update_suite_data).with("./features/sub.feature")

    @formatter.before_feature(@feature)
    @formatter.after_step_result(nil, nil, nil, :passed, nil, nil, nil)
    @formatter.after_step_result(nil, nil, nil, :failed, nil, nil, nil)
    @formatter.after_feature(@feature)
  end

  it "should submit all feature data to the server" do
    @formatter.expects(:report_all_suite_data)
    @formatter.after_features
  end

  def enhance_formatter
    @formatter.class.class_eval do
      attr_accessor :update_called
      alias_method :foo, :update_suite_failed

      def update_suite_failed
        update_called = true
        foo
      end
    end
  end

end
