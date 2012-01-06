class TlbServerRunner
  def windows?
    @is_windows ||= !!(RUBY_PLATFORM =~ /mswin/)
  end

  def exec_file
    File.join(File.dirname(__FILE__), windows? ? 'server.cmd' : 'server.sh')
  end

  def command
    windows? ? "cmd" : "/bin/bash"
  end

  def method_missing action
    exec_line = "#{command} #{exec_file} #{action}"
    Kernel.system(exec_line)

    unless $?.success?
      throw "'#{exec_line}' failed, please check stdout or stderr files."
    end
  end
end
