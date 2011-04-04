#!/usr/bin/env ruby

require 'webrick'
require 'tmpdir'
require 'yaml'

def tmp_file file_name
  path = File.join(Dir.tmpdir, file_name)
  file = File.new(path, 'w')
  File.truncate path, 0
  file.close
  file
end

def text_200 response, body = ''
  response.body = body
end

class CtrlStatus < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    sleep (ENV['SLEEP_BEFORE_STATUS'] || '0').to_i
    text_200 response, 'RUNNING'
  end
end

class CtrlSuicide < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    text_200 response, 'HALTING'
    $stderr.write "Suicide called\n"
    $stderr.flush
    req_thd = Thread.current
    exit_thd = Thread.new do
      req_thd.join
      begin
        $server.shutdown
        Kernel.exit(0)
      end
    end
  end
end

class Echo <  WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    $stdout.write "'Hello World!' to stdout\n"
    $stderr.write "'Hello World!' to stderr\n"
    $stdout.flush
    $stderr.flush
    sleep 1
    text_200 response
  end
end

class EnvDump <  WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    text_200 response, ENV.to_hash.to_yaml
  end
end

$server = WEBrick::HTTPServer.new(:Port => ENV['TLB_BALANCER_PORT'].to_i,
                                  :Logger => WEBrick::BasicLog.new(tmp_file('tlb_webrick_log').path),
                                  :AccessLog => WEBrick::BasicLog.new(tmp_file('tlb_webrick_access_log').path))

$server.mount '/control/status', CtrlStatus
$server.mount '/control/suicide', CtrlSuicide
$server.mount '/echo', Echo
$server.mount '/env/dump', EnvDump

$server.start
