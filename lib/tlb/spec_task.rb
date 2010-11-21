require File.join(File.dirname(__FILE__), 'spec_task_enhancement')
require 'rspec/core/rake_task'

class Tlb::SpecTask < RSpec::Core::RakeTask
  include Tlb::SpecTaskEnhancement
end
