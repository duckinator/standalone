require 'standalone/version'
%w[
  file
].each do |file|
  require "standalone/#{file}"
end

module Standalone
  # Your code goes here...
end
