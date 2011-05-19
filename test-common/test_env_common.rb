lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'core', 'lib'))
unless $LOAD_PATH.include? lib
  $LOAD_PATH << lib
end

require 'tlb'

def add_module_to_path mod_root
  lib = File.expand_path(File.join(mod_root, 'lib'))
  unless $LOAD_PATH.include? lib
    $LOAD_PATH << lib
  end
end
