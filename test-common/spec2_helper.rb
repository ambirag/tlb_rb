require 'rubygems'
require 'mocha'
require 'rspec'
require 'rake'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'core', 'lib', 'tlb'))

RSpec.configure do |config|
  config.mock_with :mocha
end

def tmp_file file_name
  path = File.join(Dir.tmpdir, file_name)
  file = File.new(path, 'w')
  File.truncate path, 0
  file.close
  file
end

