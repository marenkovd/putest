# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'putest/version'

Gem::Specification.new do |spec|
  spec.name          = "putest"
  spec.version       = Putest::VERSION
  spec.authors       = ["Dmitry Marenkov"]
  spec.email         = ["lt2@intertax.ru"]
  spec.summary       = "Module for builk puppet testing"
  spec.description   = "Puppet/Templates/Ruby validation + rspec tests via rake"
  spec.homepage      = ""
  spec.license       = "GPLv2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "json"
  spec.add_development_dependency "rspec", "< 3.0.0"
  spec.add_development_dependency "rspec-puppet"
  spec.add_development_dependency "puppet"
  spec.add_development_dependency "activesupport"
end