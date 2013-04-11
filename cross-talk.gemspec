# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cross-talk/version'

Gem::Specification.new do |gem|
  gem.name          = "cross-talk"
  gem.version       = Cross::Talk::VERSION
  gem.authors       = ["Joe Fredette"]
  gem.email         = ["jfredett@gmail.com"]
  gem.description   = %q{A Pub/Sub Event Management Service for Ruby Classes}
  gem.summary       = %q{A Pub/Sub Event Management Service for Ruby Classes}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'celluloid'
end
