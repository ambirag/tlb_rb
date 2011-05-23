require 'rspec/core/rake_task'
require 'rake/testtask'
require 'spec'
require 'spec/rake/spectask'

task :test => 'test:all'

namespace :test do
  task :all => [:core, :rspec2, :testunit, :cucumber, :test_unit, :rspec1]

  def specs_for *mod_names
    mod_names.each do |mod_name|
      RSpec::Core::RakeTask.new(mod_name) do |t|
        t.pattern = "#{mod_name}/test/**/*_spec.rb"
      end
    end
  end

  specs_for :core, :rspec2, :cucumber, :testunit

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
  Dir.glob('tlb/target/tlb-server*').each { |file| FileUtils.copy(file, "core/test/") }
end

task :package => :test do
  `gem build tlb-core.gemspec`
  `gem build tlb-rspec2.gemspec`
  `gem build tlb-testunit.gemspec`
  `gem build tlb-cucumber.gemspec`
  `gem build tlb-rspec1.gemspec`
end
