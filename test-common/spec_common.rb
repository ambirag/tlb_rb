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

COMMON_TEST_FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

DUMP_ENV_RUBY_SCRIPT = File.join(COMMON_TEST_FIXTURES_DIR, 'dump_env.rb')
