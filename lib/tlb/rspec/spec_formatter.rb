require 'rspec/core/formatters/base_formatter'
require 'run_data'

class Tlb::RSpec::SpecFormatter < RSpec::Core::Formatters::BaseFormatter
  include Tlb::RunData

  def initialize(*args)
    super(*args)
  end

  def example_group_started(example_proxy_group)
    suite_started(example_file_name(example_proxy_group))
  end

  def example_passed(example_proxy)
    record_suite_data(example_proxy)
  end

  def example_failed(example_proxy)
    update_suite_failed(example_file_name(example_proxy))
  end

  def example_pending(example_proxy)
    record_suite_data(example_proxy)
  end

  def start_dump
    report_all_suite_data
  end

  private
  def record_suite_data example_proxy
    update_suite_data(example_file_name(example_proxy))
  end

  def example_file_name example_proxy
    Tlb.relative_file_path(example_proxy.file_path)
  end
end
