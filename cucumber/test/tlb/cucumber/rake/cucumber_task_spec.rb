require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'tlb/cucumber/rake/cucumber_task'

describe Tlb::Cucumber::Rake::CucumberTask do

  it "should have Tlb::Cucumber::Lib and features_dir in args" do
    Tlb::Cucumber::Rake::CucumberTask.new.cucumber_opts.should == ["-r", Tlb::Cucumber::Lib::ConfigurationInflection::FILE, "-r", "features", "features"]
  end

  it "should have Tlb::Cucumber::Lib and feature_dir in args when feature_dir is set" do
    Tlb::Cucumber::Rake::CucumberTask.new do |task|
      task.features_dir = 'foo/my_features_dir'
    end.cucumber_opts.should == ["-r", Tlb::Cucumber::Lib::ConfigurationInflection::FILE, "-r", "foo/my_features_dir", "foo/my_features_dir"]
  end

  describe "when CUCUMBER_OPTS is overridden, should still hookup TLB inflection" do
    before do
      ENV['CUCUMBER_OPTS'] = 'foo bar baz'
    end

    after do
      ENV.delete('CUCUMBER_OPTS')
    end

    it "and pass other arguments along when no options set in rake-config" do
      Tlb::Cucumber::Rake::CucumberTask.new.cucumber_opts.should == ["-r", Tlb::Cucumber::Lib::ConfigurationInflection::FILE, "foo", "bar", "baz"]
      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'
    end

    it "for all task configurations" do
      Tlb::Cucumber::Rake::CucumberTask.new do |t|
        t.cucumber_opts = "hi"
      end.cucumber_opts.should == ["-r", Tlb::Cucumber::Lib::ConfigurationInflection::FILE, "foo", "bar", "baz"]
      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'

      #but still uses the overridden options
      Tlb::Cucumber::Rake::CucumberTask.new do |t|
        t.features_dir = 'my-dir'
      end.cucumber_opts.should == ["-r", Tlb::Cucumber::Lib::ConfigurationInflection::FILE, "foo", "bar", "baz"]
      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'
    end

    it "but not honor configured features_dir even if explicitly configured" do
      Tlb::Cucumber::Rake::CucumberTask.new do |task|
        task.features_dir = 'my-dir'
      end.cucumber_opts.should_not include("my-dir")
      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'
    end

    it "but dishonor all configured cucumber options" do
      Tlb::Cucumber::Rake::CucumberTask.new do |task|
        task.cucumber_opts = ['hello', 'world']
      end.cucumber_opts.should_not include("hello", "world")
      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'
    end

    it "should undo environment variable CUCUMBER_OPTS override while defining runner" do
      task_def = Tlb::Cucumber::Rake::CucumberTask.new(:bar) do |t|
        t.tlb_module_name = 'my-cucumber-module'
        class << t
          def synchronized_runner_for *args
            $env_var_value_when_creating_runner = ENV['CUCUMBER_OPTS']
            $cucumber_make_runner_caller = caller
            return Class.new do
              def run
              end
            end.new
          end
        end
      end

      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'

      task(:bar).execute

      ENV['CUCUMBER_OPTS'].should == 'foo bar baz'
      $env_var_value_when_creating_runner.should be_nil
      $cucumber_make_runner_caller.join('\n').should include('in `synchronize\'')
    end
  end

  it "should return runner wrapped in synchronized runner" do
    runner = Tlb::Cucumber::Rake::CucumberTask.new.runner
    runner.should be_a(Tlb::Cucumber::Rake::CucumberTask::SynchronizedRunner)
    runner.instance_variable_get('@runner').should be_a(Cucumber::Rake::Task::ForkedCucumberRunner)
  end


  it "should set env-var named 'module-name' for task execution process" do
    $env_vars = nil
    ENV['CUCUMBER_OPTS'] = 'hello world'

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

