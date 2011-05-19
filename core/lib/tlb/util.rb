require 'tlb'

module Tlb::Util
  def self.quote_path *fragments
    single_quote(File.expand_path(File.join(*fragments)))
  end

  def self.single_quote str
    "'#{escape_quote(str)}'"
  end

  def self.escape_quote str
    str.gsub(/'/, "\\'")
  end
end
