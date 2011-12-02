keys = Tlb::ArgProcessor.args.keys

keys.sort.each do |key|
  puts "#{key}=#{Tlb::ArgProcessor.val(key)}"
end
