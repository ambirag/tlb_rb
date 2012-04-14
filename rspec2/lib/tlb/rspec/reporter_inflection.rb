require 'rubygems'
require File.join('rspec', 'core', 'reporter')
require 'tlb'
require File.join('tlb', 'rspec', 'spec_formatter')

module Tlb::RSpec::ReporterInflection
  def self.included base
    base.class_eval do
      alias_method :report_post_formatter_injection, :report
      remove_method :report
    end
  end

  def report *args, &block
    @formatters << Tlb::RSpec::SpecFormatter.new(nil)
    report_post_formatter_injection *args, &block
  end
end

RSpec::Core::Reporter.class_eval do
  include Tlb::RSpec::ReporterInflection
end
