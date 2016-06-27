# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "hasm/version"

Gem::Specification.new do |spec|
  spec.name          = "hasm"
  spec.version       = Hasm::VERSION
  spec.authors       = ["Oleg Demchenko"]
  spec.email         = ["gracehood@mail.ru"]
  spec.summary       = Hasm::DESCRIPTION
  spec.description   = Hasm::DESCRIPTION
  spec.homepage      = "https://github.com/olegoid"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.0.0"
  spec.require_paths = ["lib"]

  spec.files = Dir["lib/**/*"] + %w(bin/hasm)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_development_dependency "commander"
  spec.add_development_dependency "colored"
  spec.add_development_dependency "terminal-table"
end