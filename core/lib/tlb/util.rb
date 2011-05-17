require File.expand_path(File.join(File.dirname(__FILE__), '..', 'tlb'))

module Tlb::Util
  def self.quote_path *fragments
    single_quote(File.expand_path(File.join(*fragments)))
  end

  def self.single_quote arg
    "'#{arg.gsub(/'/, "\\'")}'"
  end
end
