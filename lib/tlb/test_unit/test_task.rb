require 'rake'
require 'rake/testtask'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tlb'))

class Tlb::TestUnit::TestTask < Rake::TestTask
  def initialize *args
    super do |this|
      this.ruby_opts.unshift " -r#{File.expand_path(File.join(File.dirname(__FILE__), 'mediator_inflection'))} "
      yield this if block_given?
    end
  end
end
