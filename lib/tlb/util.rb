require File.expand_path(File.join(File.dirname(__FILE__), '..', 'tlb'))

module Tlb::Util
  def self.quote_path *fragments
    quote(File.expand_path(File.join(*fragments)))
  end

  def self.quote str
    "'#{escape_quote(str)}'"
  end

  def self.escape_quote str
    str.gsub(/'/, "\\'")
  end
end
