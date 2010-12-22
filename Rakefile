require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :build_tlb do
  Dir.glob("tlb-all*.jar").each { |jar| FileUtils.rm(jar) }
  sh 'ant -f tlb/build.xml package'
  Dir.glob('tlb/target/tlb-all*').each { |file| FileUtils.copy(file, ".") }
end

task :package do
  `gem build tlb-rspec1.gemspec`
end
