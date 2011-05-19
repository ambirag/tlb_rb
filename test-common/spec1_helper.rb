require File.join(File.dirname(__FILE__), 'spec_common')
require 'spec'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
