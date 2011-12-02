require 'yaml'

File.open(ENV['OUT_FILE'], 'w') do |h|
  h.write(ENV.to_hash.to_yaml)
end
