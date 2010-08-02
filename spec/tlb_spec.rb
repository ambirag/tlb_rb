require File.join(File.dirname(__FILE__), 'spec_helper')
require 'open3'
require 'parsedate'
require 'tmpdir'

describe Tlb do
  class TimedIO
    attr_reader :sem

    def initialize stream_name, after_every, &on_write
      @io = StringIO.new
      @sem = Mutex.new
      @next = Time.now
      @thd = Thread.new do
        loop do
          @now = Time.now
          if @now > @next
            @next = @now + after_every
            @sem.synchronize do
              orig_pos = @io.pos
              @io.pos = @io.length
              @io.write "#{stream_name}#{Time.now}\n"
              @io.pos = orig_pos
              on_write.call
            end
          end
        end
      end
    end

    def method_missing method, *args
      @sem.synchronize do
        @io.send(method, *args)
      end
    end
  end

  MOCK_PROCESS_ID = 33040
  SIG_TERM = 15

  def tmp_file file_name
    path = File.join(Dir.tmpdir, file_name)
    file = File.new(path, 'w')
    File.truncate path, 0
    file.close
    file
  end

  it "should wire-up streams for server" do
    Tlb.expects(:server_command).returns("foo bar")

    out_written_to = false

    time_before_io_created = Time.now

    out_stream = TimedIO.new("out", 1) do
      out_written_to = true
    end

    out_stream.stubs(:pid).returns(MOCK_PROCESS_ID)

    IO.expects(:popen).with("foo bar").returns(out_stream)

    ENV[Tlb::TLB_OUT_FILE] = (out_file = tmp_file('tlb_out_file').path)

    3.times do
      sleep 1
      File.size(out_file).should == 0
    end

    Tlb.start_server

    sleep 2

    out_file_size = 0

    out_stream.sem.synchronize do
      File.size(out_file).should > out_file_size
      out_file_size = File.size(out_file)
      out_written_to = false
    end

    sleep 2

    out_stream.sem.synchronize do
      File.size(out_file).should > out_file_size
      out_file_size = File.size(out_file)
    end

    Process.expects(:kill).with(SIG_TERM, MOCK_PROCESS_ID)

    Tlb.stop_server

    out_file_size = File.size(out_file)

    sleep 2

    File.size(out_file).should == out_file_size

    out_content = File.read(out_file)

    times_of_output(out_content, "out").inject(time_before_io_created - 1) do |old, new|
      old.should <= new
      new
    end
  end

  def times_of_output content, stream_name
    content.split("\n").map { |line| line.gsub(stream_name, '') }.map do |line|
      year, month, day_of_month, hour, minute, second, timezone, day_of_week = ParseDate.parsedate(line)
      Time.local(year, month, day_of_month, hour, minute, second)
    end
  end

  it "should generate the right command to run tlb balancer server" do
    tlb_jar = File.expand_path(Dir.glob(File.join(File.join(File.dirname(__FILE__), ".."), "tlb-all*")).first)
    Tlb.server_command.should == "java -jar #{tlb_jar} 2>&1"
  end

end
