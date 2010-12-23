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

desc "Generate RDoc"
task :doc => ['yardoc:clean', 'yardoc:generate']

namespace :yardoc do
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'doc')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + [ File.join(project_root, 'README.markdown') ]
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.markdown']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_rf doc_destination if File.exists?(doc_destination)
  end
end
