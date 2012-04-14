require File.join('rspec', 'core', 'rake_task')
require 'tlb'
require File.join('tlb', 'util')

class Tlb::RSpec::SpecTask < RSpec::Core::RakeTask
  attr_accessor :tlb_module_name

  def initialize *args
    super do |this|
      yield this if block_given?
      this.rspec_opts ||= ''
      this.rspec_opts = " --require #{Tlb::Util.quote_path(File.dirname(__FILE__), 'reporter_inflection')} " + this.rspec_opts
    end
  end

  alias_method :rspec_files_to_run, :files_to_run

  def files_to_run
    balanced_and_reordered = Tlb.balance_and_order(relative_paths(rspec_files_to_run.to_a), tlb_module_name)
    FileList[*balanced_and_reordered]
  end

  def relative_paths file_name_with_quotes
    file_name_with_quotes.map { |path_with_quotes| Tlb.relative_file_path(path_with_quotes.sub(/^"/, "").sub(/"$/, "")) }
  end
end
