require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :build_tlb do
  [Dir.glob("tlb-alien*.jar"), Dir.glob("tlb-server*.jar")].flatten.each { |jar| FileUtils.rm(jar) }
  sh '(cd tlb && ant clean package -Doffline=t)'
  Dir.glob('tlb/target/tlb-alien*').each { |file| FileUtils.copy(file, ".") }
  Dir.glob('tlb/target/tlb-server*').each { |file| FileUtils.copy(file, "spec/") }
end

task :package do
  `gem build tlb-rspec1.gemspec`
end
