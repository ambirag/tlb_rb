require 'rspec/core/rake_task'
require 'rake/testtask'

task :test => ['test:rspec', 'test:test_unit']

namespace :test do
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.pattern = 'tests/**/*_spec.rb'
  end

  Rake::TestTask.new(:test_unit) do |t|
    t.test_files = FileList['tests/**/*_test.rb']
  end
end

task :build_tlb do
  [Dir.glob("tlb-alien*.jar"), Dir.glob("tlb-server*.jar")].flatten.each { |jar| FileUtils.rm(jar) }
  sh '(cd tlb && ant clean package -Doffline=t)'
  Dir.glob('tlb/target/tlb-alien*').each { |file| FileUtils.copy(file, ".") }
  Dir.glob('tlb/target/tlb-server*').each { |file| FileUtils.copy(file, "tests/") }
end

task :package do
  `gem build tlb-rspec2.gemspec`
  `gem build tlb-testunit.gemspec`
end
