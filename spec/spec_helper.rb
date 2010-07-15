require 'rubygems'
require 'mocha'
require 'spec'
require 'rake'
$LOAD_PATH.unshift(File.dirname(__FILE__), "..", "lib")
require 'tlb'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

