$core_lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'core', 'lib'))
unless $LOAD_PATH.include? $core_lib
  $LOAD_PATH << $core_lib
end

def add_module_to_path mod_root
  lib = File.expand_path(File.join(mod_root, 'lib'))
  unless $LOAD_PATH.include? lib
    $LOAD_PATH << lib
  end
end

def uncaught_exception message
  "uncaught throw " + (RUBY_VERSION == "1.8.7" ? "`#{message.gsub('\n', '
')}'" : ('"' + message.gsub(/"/, '\"') + '"'))
end
