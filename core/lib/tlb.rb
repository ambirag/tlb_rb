require 'rubygems'
require 'open4'
require 'open5'
require 'net/http'
require 'timeout'


module Tlb
  TLB_OUT_FILE = 'TLB_OUT_FILE'
  TLB_ERR_FILE = 'TLB_ERR_FILE'
  TLB_APP = 'TLB_APP'
  DEFAULT_TLB_BALANCER_STARTUP_TIME = '120'

  module Balancer
    TLB_BALANCER_PORT = 'TLB_BALANCER_PORT'
    BALANCE_PATH = '/balance'
    SUITE_TIME_REPORTING_PATH = '/suite_time'
    SUITE_RESULT_REPORTING_PATH = '/suite_result'

    def self.host
      'localhost'
    end

    def self.port
      ENV[TLB_BALANCER_PORT] || '8019'
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

  def self.relative_file_paths file_names
    file_names.map { |file_name| relative_file_path(file_name) }
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
    class StreamPumper
      def initialize stream, file
        @stream, @file = stream, file
        @thd = Thread.new { pump }
      end

      def pump
        loop do
          data_available? && flush_stream
          Thread.current[:stop_pumping] && break
          sleep 0.1
        end
      end

      def flush_stream
        File.open(ENV[@file], 'a') do |h|
          h.write(read)
        end
      end

      def stop_pumping!
        @thd[:stop_pumping] = true
        @thd.join
      end
    end

    def initialize server_command
      pumper_type, out, err  = start(server_command)
      @out_pumper = pumper_type.new(out, TLB_OUT_FILE)
      @err_pumper = pumper_type.new(err, TLB_ERR_FILE)
    end

    def stop_pumping
      @out_pumper.stop_pumping!
      @err_pumper.stop_pumping!
    end

    def die
      Balancer.terminate
      stop_pumping
    end
  end

  class ForkBalancerProcess < BalancerProcess
    def start server_command
       
	input,err,out, @t= open5(server_command)
        @pid=@t.pid

	unless (out)
      	  raise "out was nil"
      	end
      
	return Class.new(StreamPumper) do
        def data_available?
          not @stream.eof?
        end

        def read
          @stream.read
        end
      end, out, err
    end

  
 def die
   super
   begin
     @pid = nil
     Process.wait
   rescue Errno::ECHILD
    puts "Got Errno::ECHILD"
   rescue Exception => excep
    raise excep
   end
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
      return Class.new(StreamPumper) do
        def data_available?
          @stream.ready
        end

        def read
          @stream.read_line
        end

        def stop_pumping!
          super
          @stream.close
        end
      end, buf_reader(@process.input_stream), buf_reader(@process.error_stream)
    end

    def buf_reader stream
      java.io.BufferedReader.new(java.io.InputStreamReader.new(stream))
    end

    def die
      super
      @process.destroy
      @process.waitFor
      @process = nil
    end
  end

  def self.balancer_process_type
    can_fork? ? ForkBalancerProcess : JavaBalancerProcess
  end

  def self.max_startup_time
    (ENV['TLB_BALANCER_STARTUP_MAXTIME'] || DEFAULT_TLB_BALANCER_STARTUP_TIME).to_i
  end

  def self.start_server
    Timeout::timeout(max_startup_time) do
      ENV[TLB_APP] = 'tlb.balancer.BalancerInitializer'
      bal_klass = balancer_process_type
      @balancer_process = bal_klass.new(server_command)
      Balancer.wait_for_start
    end
  rescue Timeout::Error => e
    raise "TLB server failed to start in 2 seconds. This usually happens when TLB configuration(environment variables) is incorrect. Please check your environment variable configuration."
  end

  def self.stop_server
    @balancer_process.die
  end
end
