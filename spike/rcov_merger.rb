require 'rubygems'
require 'rcov'

require 'rcov/code_coverage_analyzer'
require 'rcov/formatters/text_summary'

class RcovMerger

  def initialize(files)
    @files = files
    @formatter = Rcov::TextSummary.new
  end

  def rcov_load_aggregate_data(file)
    require 'zlib'
    begin
      old_data = nil
      Zlib::GzipReader.open(file){|gz| old_data = Marshal.load(gz) }
    rescue
      old_data = {}
    end
    old_data || {}
  end

  
  def compute
    first = rcov_load_aggregate_data(@files[0])[:coverage]
    second = rcov_load_aggregate_data(@files[1])[:coverage]
    firsts = first.instance_variable_get('@script_lines__')
    seconds = second.instance_variable_get('@script_lines__')
    firsts.merge!(seconds)
    # @files.each do |file|
    #   a = rcov_load_aggregate_data(file)
    #   File.open('/tmp/crap', 'w') do |f|
    #     f.write(a.inspect)
    #   end
    #   a[:coverage].dump_coverage_info([@formatter])
    # end
    first.dump_coverage_info([@formatter])
  end
end


RcovMerger.new(['/tmp/cov_2', '/tmp/cov_1']).compute
