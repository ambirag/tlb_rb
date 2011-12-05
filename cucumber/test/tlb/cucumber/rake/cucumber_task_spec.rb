require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/rake/cucumber_task'

describe Tlb::Cucumber::Rake::CucumberTask do

  it "should have Tlb::Cucumber::Lib and features in path" do
    Tlb::Cucumber::Rake::CucumberTask.new.cucumber_opts.should include("#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib', 'tlb', 'cucumber', 'lib'))}", "features")
  end

  it "should return runner wrapped in synchronized runner" do
    runner = Tlb::Cucumber::Rake::CucumberTask.new.runner
    runner.should be_a(Tlb::Cucumber::Rake::CucumberTask::SynchronizedRunner)
    runner.instance_variable_get('@runner').should be_a(Cucumber::Rake::Task::ForkedCucumberRunner)
  end

  it "should set env-var named 'module-name' for task execution process" do
    $env_vars = nil

    task_def = Tlb::Cucumber::Rake::CucumberTask.new(:foo) do |t|
      t.tlb_module_name = 'my-cucumber-module'
      class << t
        def runner
          synchronized_runner_for(Class.new do
            def run
              $env_vars = ENV.to_hash.dup
              $cucumber_run_caller = caller
            end
          end.new)
        end
      end
    end

    task(:foo).execute
    $env_vars[Tlb::TLB_MODULE_NAME].should == "my-cucumber-module"
    ENV[Tlb::TLB_MODULE_NAME].should be_nil
    $cucumber_run_caller.join('\n').should include('in `synchronize\'')
  end
end

