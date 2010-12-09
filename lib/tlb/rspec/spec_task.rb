require 'rspec/core/rake_task'

class Tlb::RSpec::SpecTask < RSpec::Core::RakeTask
  attr_accessor :tlb_out

  def initialize *args
    path_to_tlb = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tlb'))
    path_to_spec_formatter = File.expand_path(File.join(File.dirname(__FILE__), 'spec_formatter'))
    self.tlb_out = '/dev/null'
    super do |this|
      yield this if block_given?
      this.rspec_opts ||= ''
      this.rspec_opts = " --require #{path_to_tlb} --require #{path_to_spec_formatter} --format 'Tlb::RSpec::SpecFormatter:#{this.tlb_out}' " + this.rspec_opts
    end
  end

  alias_method :rspec_files_to_run, :files_to_run

  def files_to_run
    balanced_and_reordered = Tlb.balance_and_order(rspec_files_to_run.to_a)
    FileList[*balanced_and_reordered]
  end
end
