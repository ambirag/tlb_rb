require File.join(File.dirname(__FILE__), 'spec_task_enhancement')
require 'spec/rake/spectask'

class Tlb::TlbSpecTask < Spec::Rake::SpecTask
  include Tlb::SpecTaskEnhancement
end
