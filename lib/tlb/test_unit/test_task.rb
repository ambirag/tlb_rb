require 'rake'
require 'rake/testtask'

class Tlb::TestUnit::TestTask < Rake::TestTask
  def initialize *args
    super do |this|
      this.libs << File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      this.ruby_opts.unshift " -r#{File.join('tlb', 'test_unit', 'mediator_inflection.rb')} "
      yield this if block_given?
    end
  end
end
