$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "tlb"))
require 'rubygems'
require 'open4'

module Tlb
  TLB_OUT_FILE = "TLB_OUT_FILE"
  TLB_ERR_FILE = "TLB_ERR_FILE"

  def self.root_dir
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end

  def self.tlb_jar
    File.expand_path(Dir.glob(File.join(root_dir, "tlb-all*")).first)
  end

  def self.server_command
    "java -jar #{tlb_jar}"
  end

  def self.write_to_file file_var, clob
    File.open(ENV[file_var], 'a') do |h|
      h.write(clob)
    end
  end

  def self.start_server
    @pid, input, out, err = Open4.popen4(server_command)
    @out_pumper = stream_pumper_for(out, TLB_OUT_FILE)
    @err_pumper = stream_pumper_for(err, TLB_ERR_FILE)
  end

  def self.stream_pumper_for stream, dump_file
    Thread.new do
      loop do
        stream.eof? || write_to_file(dump_file, stream.read)
        Thread.current[:stop_pumping] && break
        sleep 1
      end
    end
  end

  def self.stop_server
    Process.kill(Signal.list["TERM"], @pid)
    @out_pumper[:stop_pumping] = true
    @err_pumper[:stop_pumping] = true
    @out_pumper.join
    @err_pumper.join
  end
end
