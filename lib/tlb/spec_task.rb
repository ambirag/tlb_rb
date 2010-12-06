require 'spec/rake/spectask'

class Tlb::SpecTask < Spec::Rake::SpecTask
  attr_accessor :tlb_out

  def initialize *args
    path_to_tlb = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tlb'))
    path_to_spec_formatter = File.expand_path(File.join(File.dirname(__FILE__), 'spec_formatter'))
    self.tlb_out = '/dev/null'
    super do |this|
      yield this if block_given?
      this.spec_opts.unshift "--require #{path_to_tlb},#{path_to_spec_formatter} --format 'Tlb::SpecFormatter:#{this.tlb_out}'"
    end
  end

  alias_method :rspec_spec_file_list, :spec_file_list

  def spec_file_list
    balanced_and_reordered = Tlb.balance_and_order(rspec_spec_file_list.to_a)
    FileList[*balanced_and_reordered]
  end
end
