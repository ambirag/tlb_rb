require 'rake'
require 'rake/testtask'

class Tlb::TestUnit::TestTask < Rake::TestTask
  def initialize *args
    super
    @libs << File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    @ruby_opts.unshift " -r#{File.join('tlb', 'test_unit', 'mediator_inflection.rb')} "
  end
end
