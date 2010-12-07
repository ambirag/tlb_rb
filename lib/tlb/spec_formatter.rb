require 'spec/runner/formatter/silent_formatter'

class Tlb::SpecFormatter < Spec::Runner::Formatter::SilentFormatter
  class Suite < Struct.new(:file_name, :start_time, :end_time, :failed)
    MILLS_PER_SEC = 1000

    def initialize(file_name, start_time)
      super(file_name, start_time, start_time, false)
    end

    def run_time
      ((end_time - start_time)*MILLS_PER_SEC).to_i
    end

    def report_to_tlb
      rel_file_name = Tlb.relative_file_path(file_name)
      Tlb.suite_time(rel_file_name, run_time)
      Tlb.suite_result(rel_file_name, failed)
    end
  end

  def initialize(*args)
    super(*args)
    @suites = []
  end

  def example_group_started(example_proxy_group)
    file_name = example_file_name(example_proxy_group)
    @suites << Tlb::SpecFormatter::Suite.new(file_name, Time.now)
  end

  def example_passed(example_proxy)
    record_suite_data(example_proxy)
  end

  def example_failed(example_proxy, *ignore)
    record_suite_data(example_proxy) do |suite|
      suite.failed = true
    end
  end

  def example_pending(example_proxy, *ignore)
    record_suite_data(example_proxy)
  end

  def start_dump
    @suites.each do |suite_time|
      suite_time.report_to_tlb
    end
  end

  private
  def record_suite_data example_proxy
    file_name = example_file_name(example_proxy)
    if (suite = @suites.last) #stupid framework :: retarded fix (this is necessary since rspec creates example_proxies for every example it runs, as though its an independent spec-group)
      suite.end_time = Time.now
      block_given? && yield(suite)
    end
  end

  def example_file_name example_proxy
    example_proxy.location ? (@last_known_file = example_proxy.location.scan(/^(.+?):\d+(:.*)?$/).flatten.first) : @last_known_file
  end
end
