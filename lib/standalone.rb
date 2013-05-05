%w[
  version
  file
  env
].each do |file|
  require "standalone/#{file}"
end

module Standalone
  # This removes a constant (to avoid "already initialized constant"), then
  # defines it to the value specified in the Standalone module.
  def self.enable!
    self.constants.each do |x|
      Object.instance_eval do
        remove_const x if const_defined?(x)
        const_set(x, Standalone.const_get(x))
      end
    end
  end
end
