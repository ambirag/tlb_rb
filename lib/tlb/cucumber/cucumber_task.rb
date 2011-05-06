require 'cucumber/rake/task'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tlb'))
require 'tlb/util'
require 'tlb/cucumber/configuration_inflection'

module Tlb
  module Cucumber
    class CucumberTask < ::Cucumber::Rake::Task

      def initialize(*args)
        super(args) do |this|
          yeild this if block_given?
          this.cucumber_opts ||= []
          this.cucumber_opts = [this.cucumber_opts, '--require', "#{Tlb::Util.quote_path(File.dirname(__FILE__), 'formatter_callback')}"].flatten
          this.cucumber_opts = [this.cucumber_opts, '--require', "#{Tlb::Util.quote_path(File.dirname(__FILE__), 'configuration_inflection')}"].flatten
          this.cucumber_opts = [this.cucumber_opts, '--format', 'Tlb::Cucumber::FormatterCallback'].flatten
          this.libs = [this.libs, "#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))}"].flatten
        end
      end
    end
  end
end
