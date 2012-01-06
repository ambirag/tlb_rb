require 'rspec/core/rake_task'
require 'rake/testtask'
require 'spec'
require 'spec/rake/spectask'

task :test => 'test:all'

namespace :test do
  task :all => [:core, :rspec2, :testunit, :cucumber, :test_unit, :rspec1, :server]

  def specs_for *mod_names
    mod_names.each do |mod_name|
      RSpec::Core::RakeTask.new(mod_name) do |t|
        t.pattern = "#{mod_name}/test/**/*_spec.rb"
      end
    end
  end

  specs_for :core, :rspec2, :cucumber, :testunit, :server

  Spec::Rake::SpecTask.new(:rspec1) do |t|
    t.spec_files = FileList['rspec1/test/**/*_spec.rb']
  end

  Rake::TestTask.new(:test_unit) do |t|
    t.test_files = FileList['**/*_test.rb']
  end
end

task :build_tlb do
  [Dir.glob("**/tlb-alien*.jar"), Dir.glob("**/tlb-server*.jar")].flatten.each { |jar| FileUtils.rm(jar) }
  sh '(cd tlb && ant clean package -Doffline=t)'
  Dir.glob('tlb/target/tlb-alien*').each { |file| FileUtils.copy(file, "core") }
  Dir.glob('tlb/target/tlb-server*').each do |file|
    FileUtils.copy(file, "core/test/")
    FileUtils.copy(file, "server/lib/")
  end
  Dir.glob('tlb/server/server*').each do |file|
    if file =~ /(sh|cmd|bat)$/
      FileUtils.copy(file, "server/lib/")
    end
  end
end

task :package => [:test, :build_gems]

task :build_gems do
  `gem build tlb-core.gemspec`
  `gem build tlb-rspec2.gemspec`
  `gem build tlb-testunit18.gemspec`
  `gem build tlb-testunit19.gemspec`
  `gem build tlb-cucumber.gemspec`
  `gem build tlb-rspec1.gemspec`
  `gem build tlb-server.gemspec`
end
