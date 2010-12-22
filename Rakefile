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
  Dir.glob("tlb-all*.jar").each { |jar| FileUtils.rm(jar) }
  sh 'ant -f tlb/build.xml package'
  Dir.glob('tlb/target/tlb-all*').each { |file| FileUtils.copy(file, ".") }
end

task :package do
  `gem build tlb-rspec2.gemspec`
  `gem build tlb-testunit.gemspec`
end
