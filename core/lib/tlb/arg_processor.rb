require 'tlb'

module Tlb::ArgProcessor

  FILE = File.expand_path(__FILE__)

  @@args = { }

  def self.val key
    @@args[key.to_s]
  end

  def self.args
    @@args
  end

  def self.parse!
    indexes_to_remove = []

    ARGV.each_with_index do |arg, idx|
      matches = arg.scan(/^\s*-Arg:(.+?)=(.+?)\s*$/).flatten
      unless matches.empty?
        @@args[matches.first] = matches.last
        indexes_to_remove << idx
      end
    end

    indexes_to_remove.reverse.each do |idx|
      ARGV.delete_at(idx)
    end
  end
end

Tlb::ArgProcessor.parse!
