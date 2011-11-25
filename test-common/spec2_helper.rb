require File.join(File.dirname(__FILE__), 'spec_common')
require 'rspec'

unless $spec_2_config_loaded
  RSpec.configure do |config|
    config.mock_with :mocha
  end
  $spec_2_config_loaded = true
end
