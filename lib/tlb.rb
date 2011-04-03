require 'rubygems'
require 'open4'
require 'net/http'

TLB_RB_LIB = File.expand_path(File.dirname(__FILE__))
unless $LOAD_PATH.include? TLB_RB_LIB
  $LOAD_PATH << TLB_RB_LIB
end

module Tlb
  TLB_OUT_FILE = 'TLB_OUT_FILE'
  TLB_ERR_FILE = 'TLB_ERR_FILE'
  TLB_APP = 'TLB_APP'

  module Balancer
    TLB_BALANCER_PORT = 'TLB_BALANCER_PORT'
    BALANCE_PATH = '/balance'
    SUITE_TIME_REPORTING_PATH = '/suite_time'
    SUITE_RESULT_REPORTING_PATH = '/suite_result'

    def self.host
      'localhost'
    end

    def self.port
      ENV[TLB_BALANCER_PORT]
    end

    def self.send path, data
      Net::HTTP.start(host, port) do |h|
        res = h.post(path, data)
        res.value
        res.body
      end
    end

    def self.get path
      Net::HTTP.get_response(host, path, port).body
    end

    def self.running?
      get("/control/status") == "RUNNING"
    rescue
      false
    end

    def self.terminate
      get("/control/suicide")
    end

    def self.wait_for_start
      loop do
        begin
          break if running?
        rescue
          #ignore
        end
      end
    end
  end

  module RSpec
  end

  module TestUnit
  end

  def self.relative_file_path file_name
    abs_file_name = File.expand_path(file_name)
    rel_file_name = abs_file_name.sub(/^#{Dir.pwd}/, '.')
  end

  def self.balance_and_order file_set
    ensure_server_running
    Balancer.send(Balancer::BALANCE_PATH, file_set.join("\n")).split("\n")
  end

  def self.suite_result suite_name, result
    ensure_server_running
    Balancer.send(Balancer::SUITE_RESULT_REPORTING_PATH, "#{suite_name}: #{result}")
  end

  def self.suite_time suite_name, mills
    ensure_server_running
    Balancer.send(Balancer::SUITE_TIME_REPORTING_PATH, "#{suite_name}: #{mills}")
  end

  def self.fail_as_balancer_is_not_running
    raise "Balancer server must be started before tests are run."
  end

  def self.ensure_server_running
    server_running? || fail_as_balancer_is_not_running
  end

  def self.server_running?
    Balancer.running?
  end

  def self.root_dir
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end

  def self.tlb_jar
    File.expand_path(Dir.glob(File.join(root_dir, "tlb-alien*")).first)
  end

  def self.server_command
    "java -jar #{tlb_jar}"
  end

  def self.can_fork?
    RUBY_PLATFORM != 'java'
  end

  class BalancerProcess
    def initialize server_command
      out, err  = start(server_command)
      @out_pumper = stream_pumper_for(out, TLB_OUT_FILE)
      @err_pumper = stream_pumper_for(err, TLB_ERR_FILE)
    end

    def stop_pumping
      @out_pumper[:stop_pumping] = true
      @err_pumper[:stop_pumping] = true
      @out_pumper.join
      @err_pumper.join
    end

    def die
      Balancer.terminate
      stop_pumping
    end

    def stream_pumper_for stream, dump_file
      Thread.new do
        begin
          loop do
            data_available_on?(stream) || BalancerProcess.write_to_file(dump_file, read_from(stream))
            Thread.current[:stop_pumping] && break
            sleep 0.1
          end
        rescue
          puts $!.inspect
          puts $!.message
          puts $!.backtrace
        end
      end
    end

    def self.write_to_file file_var, clob
      File.open(ENV[file_var], 'a') do |h|
        h.write(clob)
      end
    end
  end

  class ForkBalancerProcess < BalancerProcess
    def start server_command
      @pid, input, out, err = Open4.popen4(server_command)
      unless (out)
        raise "out was nil"
      end
      return out, err
    end

    def die
      super
      @pid = nil
      Process.wait
    end

    def data_available_on? stream
      stream.eof?
    end

    def read_from stream
      stream.read
    end
  end

  class JavaBalancerProcess < BalancerProcess
    def start server_command
      require 'java'
      pb = java.lang.ProcessBuilder.new(server_command.split)
      ENV.each do |key, val|
        pb.environment[key] = val
      end
      @process = pb.start()
      return buf_reader(@process.input_stream), buf_reader(@process.error_stream)
    end

    def buf_reader stream
      java.io.BufferedReader.new(java.io.InputStreamReader.new(stream))
    end

    def data_available_on? reader
      reader.ready
    end

    def read_from reader
      reader.read_line
    end
  end

  def self.balancer_process_type
    can_fork? ? ForkBalancerProcess : JavaBalancerProcess
  end

  def self.start_server
    ENV[TLB_APP] = 'tlb.balancer.BalancerInitializer'
    bal_klass = balancer_process_type
    @balancer_process = bal_klass.new(server_command)
    Balancer.wait_for_start
  end

  def self.stop_server
    @balancer_process.die
  end
end
