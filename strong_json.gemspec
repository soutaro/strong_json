# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strong_json/version'

Gem::Specification.new do |spec|
  spec.name          = "strong_json"
  spec.version       = StrongJSON::VERSION
  spec.authors       = ["Soutaro Matsumoto"]
  spec.email         = ["matsumoto@soutaro.com"]
  spec.summary       = "Type check JSON objects"
  spec.description   = "Type check JSON objects"
  spec.homepage      = "https://github.com/soutaro/strong_json"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
