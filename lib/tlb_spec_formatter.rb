require 'spec/runner/formatter/silent_formatter'

class Tlb::TlbSpecFormatter < Spec::Runner::Formatter::SilentFormatter
  class SuiteTime < Struct.new(:file_name, :start_time, :end_time)
    MILLS_PER_SEC = 1000

    def initialize(file_name, start_time)
      super(file_name, start_time, start_time)
    end

    def run_time
      ((end_time - start_time)*MILLS_PER_SEC).to_i
    end

    def for_file? new_file
      File.identical?(file_name, new_file)
    end

    def report_to_tlb
      Tlb.suite_time(file_name, run_time)
    end
  end

  def initialize(*args)
    super(*args)
    @suite_times = []
  end

  def example_group_started(example_proxy_group)
    file_name = example_file_name(example_proxy_group)
    @suite_times << Tlb::TlbSpecFormatter::SuiteTime.new(file_name, Time.now)
  end

  def example_passed(example_proxy)
    record_end_time(example_proxy)
  end

  def example_failed(example_proxy, *ignore)
    record_end_time(example_proxy)
  end

  def example_pending(example_proxy, *ignore)
    record_end_time(example_proxy)
  end

  def start_dump
    @suite_times.each do |suite_time|
      suite_time.report_to_tlb
    end
  end

  private
  def record_end_time example_proxy
    file_name = example_file_name(example_proxy)
    suite_time = @suite_times.find { |suite_time| suite_time.for_file?(file_name) }
    suite_time && (suite_time.end_time = Time.now)
  end

  def example_file_name example_proxy
    example_proxy.location.scan(/^(.+?):\d+$/).flatten.first
  end
end
