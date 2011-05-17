require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/rake/cucumber_task'

describe Tlb::Cucumber::Rake::CucumberTask do

  before do
    @task = Tlb::Cucumber::Rake::CucumberTask.new
  end

  it "should have Tlb::Cucumber::Lib and features in path" do
    @task.cucumber_opts.should include("#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib', 'tlb', 'cucumber', 'lib'))}", "features")
  end
end

