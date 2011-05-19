require 'rubygems'
require 'mocha'
require 'rake'
require File.join(File.dirname(__FILE__), 'test_env_common')

def tmp_file file_name
  path = File.join(Dir.tmpdir, file_name)
  file = File.new(path, 'w')
  File.truncate path, 0
  file.close
  file
end
