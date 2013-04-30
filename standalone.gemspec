# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'standalone/version'

Gem::Specification.new do |spec|
  spec.name          = "standalone"
  spec.version       = Standalone::VERSION
  spec.authors       = ["Nick Markwell"]
  spec.email         = ["nick@duckinator.net"]
  spec.description   = %q{Ruby standard library implementation with no dependencies.}
  spec.summary       = %q{Ruby standard library implementation with no dependencies.}
  spec.homepage      = "https://github.com/duckinator/standalone"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "mspec"
end
