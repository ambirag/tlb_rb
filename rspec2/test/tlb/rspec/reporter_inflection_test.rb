require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')
require 'tlb'
require 'stringio'

require 'tlb/rspec/reporter_inflection'
require 'test/unit'

# can't test rspec integration code while using it, so have written this test in test::unit

class Tlb::RSpec::ReporterInflectionTest < Test::Unit::TestCase
  def setup
    @reporter_class = Class.new do
      attr_reader :formatters, :report_called_with_args, :formatters_while_reporting
      def initialize *args
        @formatters = *args
      end

      def report *args
        @report_called_with_args = args
        @formatters_while_reporting = @formatters.dup
        yield :crap if block_given?
      end

      include Tlb::RSpec::ReporterInflection
    end

    @reporter = @reporter_class.new(:some, :other, :formatters)
    assert_equal 3, @reporter.formatters.length
  end

  def test_rspec_reporter_enhanement
    assert RSpec::Core::Reporter.included_modules.include?(Tlb::RSpec::ReporterInflection)
  end

  def test_reporter_is_passed_in_invocation_arguments
    @reporter.report(:hello, "world", 42)
    assert_equal [:hello, "world", 42], @reporter.report_called_with_args
  end

  def test_reporter_is_passed_in_given_block
    given_argument = nil
    @reporter.report do |arg|
      given_argument = arg
    end
    assert_equal :crap, given_argument
  end

  def test_hooks_up_tlb_spec_formatter
    @reporter.report

    assert_equal 4, @reporter.formatters.length

    assert @reporter.formatters.include?(:some)
    assert @reporter.formatters.include?(:other)
    assert @reporter.formatters.include?(:formatters)

    assert_equal Tlb::RSpec::SpecFormatter, @reporter.formatters[3].class
  end

  def test_hooks_up_tlb_spec_formatter_before_calling_actual_report_method
    @reporter.report

    assert_equal 4, @reporter.formatters_while_reporting.length
    assert_equal Tlb::RSpec::SpecFormatter, @reporter.formatters_while_reporting[3].class
  end
end
