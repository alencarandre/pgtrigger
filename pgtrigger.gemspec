# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pgtrigger/version"

Gem::Specification.new do |spec|
  spec.name          = "pgtrigger"
  spec.version       = Pgtrigger::VERSION
  spec.authors       = ["André Alencar"]
  spec.email         = ["andreluis88@gmail.com"]

  spec.summary       = "Create PostgreSQL trigger with ActiveRecord Migration"
  spec.description   = "Create PostgreSQL trigger with ActiveRecord Migration"
  spec.homepage      = "https://github.com/alencarandre/pgtrigger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
