require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :build_tlb do
  Dir.glob("tlb-all*.jar").each { |jar| FileUtils.rm(jar) }
  sh 'ant -f tlb/build.xml package'
  Dir.glob('tlb/target/tlb-all*').each { |file| FileUtils.copy(file, ".") }
end
