$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "tlb"))
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "tlb", "rspec"))
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "tlb", "test_unit"))

require 'rubygems'
require 'open4'
require 'net/http'

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

    def self.wait_for_start
      loop do
        begin
          TCPSocket.new(host, port)
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
    ENV[TLB_APP] = 'com.github.tlb.balancer.BalancerInitializer'
    @pid, input, out, err = Open4.popen4(server_command)
    @out_pumper = stream_pumper_for(out, TLB_OUT_FILE)
    @err_pumper = stream_pumper_for(err, TLB_ERR_FILE)
    Balancer.wait_for_start
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
    @pid = nil
    @out_pumper[:stop_pumping] = true
    @err_pumper[:stop_pumping] = true
    @out_pumper.join
    @err_pumper.join
    Process.wait
  end
end
