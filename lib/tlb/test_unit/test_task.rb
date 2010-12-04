require 'rake'
require 'rake/testtask'

class Tlb::TestUnit::TestTask < Rake::TestTask
  def initialize *args
    super
    @ruby_opts.unshift " -r#{File.expand_path(File.join(File.dirname(__FILE__), 'mediator_inflection.rb'))} "
  end
end
