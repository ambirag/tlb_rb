require 'spec/rake/spectask'
require 'tlb'
require 'tlb/util'

class Tlb::SpecTask < Spec::Rake::SpecTask
  attr_accessor :tlb_out

  def initialize *args
    self.tlb_out = '/dev/null'
    super do |this|
      yield this if block_given?
      this.spec_opts.unshift "--require #{Tlb::Util.quote_path(File.dirname(__FILE__), 'spec_formatter')} --format 'Tlb::SpecFormatter:#{Tlb::Util.escape_quote(this.tlb_out)}'"
    end
  end

  alias_method :rspec_spec_file_list, :spec_file_list

  def spec_file_list
    balanced_and_reordered = Tlb.balance_and_order(rspec_spec_file_list.to_a)
    FileList[*balanced_and_reordered]
  end
end
