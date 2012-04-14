require File.join('rspec', 'core', 'formatters', 'base_formatter')
require 'tlb'
require File.join('tlb', 'run_data')
require 'stringio'

class Tlb::RSpec::SpecFormatter < RSpec::Core::Formatters::BaseFormatter
  include Tlb::RunData

  def initialize(*args)
    super(*args)
  end

  def example_group_started(example_group)
    suite_started(example_file_name(example_group))
  end

  def example_group_finished(example_group)
    record_suite_data(example_group)
  end

  def example_passed(example)
    record_suite_data(example)
  end

  def example_failed(example)
    update_suite_failed(example_file_name(example))
  end

  def example_pending(example)
    record_suite_data(example)
  end

  def start_dump
    report_all_suite_data
  end

  private
  def record_suite_data example
    update_suite_data(example_file_name(example))
  end

  def example_file_name example
    Tlb.relative_file_path(example.file_path)
  end
end
