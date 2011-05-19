require 'tlb'

module Tlb::RunData
  class Suite < Struct.new(:identity, :start_time, :end_time, :failed)
    MILLS_PER_SEC = 1000

    def initialize(identity, start_time)
      super(identity, start_time, start_time, false)
    end

    def run_time
      ((end_time - start_time)*MILLS_PER_SEC).to_i
    end

    def for_id? new_identity
      identity == new_identity
    end

    def report_to_tlb
      Tlb.suite_time(identity, run_time)
      Tlb.suite_result(identity, failed)
    end
  end

  def suite_started identity
    unless (suites.last && suites.last.for_id?(identity))
      suites << Tlb::RunData::Suite.new(identity, Time.now)
    end
  end

  def update_suite_data identity
    if (suite = suites.last) #stupid framework :: retarded fix (this is necessary since rspec-1[don't know if rspec-2 is as stupid too] creates example_proxies for every example it runs, as though its an independent spec-group)
      suite.end_time = Time.now
      block_given? && yield(suite)
    end
  end

  def update_suite_failed identity
    update_suite_data(identity) do |suite|
      suite.failed = true
    end
  end

  def report_all_suite_data
    suites.each do |suite_time|
      suite_time.report_to_tlb
    end
  end

  private

  def suites
    @suites ||= []
  end
end
