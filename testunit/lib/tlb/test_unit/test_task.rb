require 'rake'
require 'rake/testtask'
require 'tlb'
require 'tlb/util'
require 'tlb/arg_processor'

class Tlb::TestUnit::TestTask < Rake::TestTask
  attr_accessor :tlb_module_name

  def initialize *args
    super do |this|
      this.ruby_opts.unshift " -r#{Tlb::Util.quote_path(File.dirname(__FILE__), 'mediator_inflection')} "
      this.ruby_opts.unshift " -r#{Tlb::Util.quote_path(Tlb::ArgProcessor::FILE)} "
      yield this if block_given?
    end
  end

  def option_list
    tlb_module_name ? (super + " -Arg:#{Tlb::TLB_MODULE_NAME}=#{tlb_module_name} ") : super
  end
end
