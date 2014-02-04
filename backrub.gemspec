# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backrub'

Gem::Specification.new do |spec|
  spec.name          = "backrub"
  spec.version       = Backrub::VERSION
  spec.authors       = ["Bouke van der Bijl"]
  spec.email         = ["boukevanderbijl@gmail.com"]
  spec.description = spec.summary = %q{Redis-based pubsub system with a backlog}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
